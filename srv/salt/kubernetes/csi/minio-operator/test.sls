# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{%- from tpldir ~ "/map.jinja" import minio with context %}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- set public_domain = pillar['public-domain'] %}

query-minio-ui:
  http.wait_for_successful_query:
    - watch:
      - cmd: minio-operator
      - cmd: minio-ingress
    - name: https://{{ minio.ingress_host }}.{{ public_domain }}/minio/health/ready
    - wait_for: 120
    - request_interval: 5
    - status: 403