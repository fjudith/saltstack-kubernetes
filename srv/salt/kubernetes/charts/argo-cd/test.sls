# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import argo_cd with context %}
{%- set public_domain = pillar['public-domain'] -%}

query-argo-cd-web:
  http.wait_for_successful_query:
    - watch:
      - cmd: argo-cd
      - cmd: argo-cd-ingress
    - name: https://{{ argo_cd.ingress_host }}.{{ public_domain }}
    - wait_for: 120
    - request_interval: 5
    - status: 200