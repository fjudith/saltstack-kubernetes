# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import tekton with context %}
{%- set public_domain = pillar['public-domain'] -%}

query-tekton:
  http.wait_for_successful_query:
    - watch:
      - cmd: tekton
      - cmd: tekton-ingress
    - name: https://{{ tekton.ingress_host }}.{{ public_domain }}
    - wait_for: 120
    - request_interval: 5
    - status: 200