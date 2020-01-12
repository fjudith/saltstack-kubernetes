# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{%- from tpldir ~ "/map.jinja" import kubeless with context %}
{%- set public_domain = pillar['public-domain'] %}

query-kubeless-ui:
  http.wait_for_successful_query:
    - watch:
      - cmd: kubeless-ui
      - cmd: kubeless-ingress
    - name: https://{{ kubeless.ingress_host }}.{{ public_domain }}/
    - wait_for: 120
    - request_interval: 5
    - status: 200