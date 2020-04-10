# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import falco with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- from "kubernetes/map.jinja" import storage with context -%}

falco:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/falco/values.yaml
      - cmd: falco-namespace
      - cmd: falco-fetch-charts
    - cwd: /srv/kubernetes/manifests/falco/falco
    - name: |
        helm repo update && \
        helm upgrade --install falco --namespace falco \
            -f /srv/kubernetes/manifests/falco/values.yaml \
            "./" --wait --timeout 5m