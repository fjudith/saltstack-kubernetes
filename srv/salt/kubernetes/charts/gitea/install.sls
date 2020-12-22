# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import gitea with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- from "kubernetes/map.jinja" import storage with context -%}

gitea:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/gitea/values.yaml
      - cmd: gitea-namespace
      - cmd: gitea-fetch-charts
    - onlyif: kubectl get storageclass | grep \(default\)
    - cwd: /srv/kubernetes/manifests/gitea/gitea
    - name: |
        helm repo update && \
        helm upgrade --install gitea --namespace gitea \
            -f /srv/kubernetes/manifests/gitea/values.yaml \
            "./" --wait --timeout 5m
