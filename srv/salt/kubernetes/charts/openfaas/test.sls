# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import openfaas with context %}
{%- set public_domain = pillar['public-domain'] -%}

query-openfaas-web:
  http.wait_for_successful_query:
    - watch:
      - cmd: openfaas
      - cmd: openfaas-ingress
    - name: https://{{ openfaas.ingress_host }}.{{ public_domain }}/healthz
    - match: OK
    - match_type: string
    - wait_for: 120
    - request_interval: 5
    - status: 200