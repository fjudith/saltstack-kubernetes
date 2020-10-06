# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import argo with context %}

/opt/argo-linux-amd64-v{{ argo.version }}:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/opt/argo-linux-amd64-v{{ argo.version }}/argo-linux-amd64.gz:
  file.managed:
    - require:
      - file: /opt/argo-linux-amd64-v{{ argo.version }}
    - source: https://github.com/argoproj/argo/releases/download/v{{ argo.version }}/argo-linux-amd64.gz
    - skip_verify: true
    - user: root
    - group: root

argo-client:
  cmd.run:
    - require:
      - file: /opt/argo-linux-amd64-v{{ argo.version }}/argo-linux-amd64.gz
    - cwd: /opt/argo-linux-amd64-v{{ argo.version }}
    - name: |
        gunzip --force argo-linux-amd64.gz && \
        chmod +x argo-linux-amd64 && \
        rm -f argo-linux-amd64.gz
  file.symlink:
    - name: /usr/local/bin/argo
    - target: /opt/argo-linux-amd64-v{{ argo.version }}/argo-linux-amd64

argo:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/argo/values.yaml
      - file: /srv/kubernetes/manifests/argo/rbac.yaml
      - cmd: argo-namespace
      - cmd: argo-fetch-charts
    - cwd: /srv/kubernetes/manifests/argo/argo
    - name: |
        kubectl -n argo apply -f /srv/kubernetes/manifests/argo/rbac.yaml
        kubectl apply -f ./crds/ && \
        helm upgrade --install argo --namespace argo \
            --values /srv/kubernetes/manifests/argo/values.yaml \
            "./" --wait --timeout 5m