# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import argo with context %}
{%- set public_domain = pillar['public-domain'] -%}

query-argo-web:
  http.wait_for_successful_query:
    - watch:
      - cmd: argo
      - cmd: argo-ingress
    - name: https://{{ argo.ingress_host }}.{{ public_domain }}
    - wait_for: 120
    - request_interval: 5
    - status: 200

query-argo-minio:
  http.wait_for_successful_query:
    - watch:
      - cmd: argo-minio
      - cmd: argo-ingress
    - name: https://{{ argo.ingress_host }}-minio.{{ public_domain }}/minio/health/ready
    - wait_for: 240
    - request_interval: 5
    - status: 200