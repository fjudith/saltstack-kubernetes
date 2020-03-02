# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import proxyinjector with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

query-proxyinjector-demo:
  http.wait_for_successful_query:
    - watch:
      - cmd: proxyinjector-demo
      - cmd: proxyinjector-demo-ingress
    - name: https://{{ proxyinjector.ingress_host }}.{{ public_domain }}
    - wait_for: 120
    - request_interval: 5
    - status: 200