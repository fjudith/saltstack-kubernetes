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

/opt/argocd-linux-amd64-v{{ argo.cd_version }}:
  file.managed:
    - source: https://github.com/argoproj/argo/releases/download/v{{ argo.cd_version }}/argocd-linux-amd64
    - skip_verify: True
    - mode: "0755"
    - user: root
    - group: root
    - if_missing: /opt/argocd-linux-amd64-v{{ argo.cd_version }}

/usr/local/bin/argocd:
  file.symlink:
    - target: /opt/argocd-linux-amd64-v{{ argo.cd_version }}

argo-cd:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/argo/argo-cd.yaml
      - cmd: argo-namespace
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/argo/argo-cd.yaml

argo-workflow:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/argo/argo-workflow.yaml
      - cmd: argo-namespace
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/argo/argo-workflow.yaml