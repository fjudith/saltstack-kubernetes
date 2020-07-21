# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import argo with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import storage with context -%}

/opt/argo-linux-amd64-v{{ argo.version }}:
  file.managed:
    - source: https://github.com/argoproj/argo/releases/download/v{{ argo.version }}/argo-linux-amd64
    - skip_verify: True
    - mode: "0755"
    - user: root
    - group: root
    - if_missing: /opt/argo-linux-amd64-v{{ argo.version }}

/usr/local/bin/argo:
  file.symlink:
    - target: /opt/argo-linux-amd64-v{{ argo.version }}

argo:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/argo/workflow-values.yaml
      - cmd: argo-namespace
      - cmd: argo-fetch-charts
    - cwd: /srv/kubernetes/manifests/argo/argo
    - name: |
        kubectl apply -f ./crds/ && \
        helm upgrade --install argo --namespace argo \
            --values /srv/kubernetes/manifests/argo/workflow-values.yaml \
            "./" --wait --timeout 5m