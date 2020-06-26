# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{%- from tpldir ~ "/map.jinja" import minio_operator with context %}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- set public_domain = pillar['public-domain'] %}

query-minio-ui:
  http.wait_for_successful_query:
    - watch:
      - cmd: minio-operator
      - cmd: minio-ingress
    - name: https://{{ minio_operator.ingress_host }}.{{ public_domain }}/minio/health/ready
    - wait_for: 240
    - request_interval: 5
    - status: 200