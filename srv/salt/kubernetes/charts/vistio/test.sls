# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import vistio with context %}
{%- set public_domain = pillar['public-domain'] -%}

query-vitio-ui:
  http.wait_for_successful_query:
    - watch:
      - cmd: vistio
      - cmd: vistio-ingress
    - name: https://{{ vistio.ingress_host }}.{{ public_domain }}
    - wait_for: 120
    - request_interval: 5
    - status: 200

query-vistio-api:
  http.wait_for_successful_query:
    - watch:
      - cmd: vistio
      - cmd: vistio-ingress
    - name: https://{{ vistio.ingress_host }}-api.{{ public_domain }}
    - wait_for: 120
    - request_interval: 5
    - status: 200