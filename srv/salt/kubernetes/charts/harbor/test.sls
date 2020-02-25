# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import harbor with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

query-harbor-core:
  http.wait_for_successful_query:
    - watch:
      - cmd: harbor
    - name: https://{{ harbor.core_ingress_host }}.{{ public_domain }}
    - wait_for: 120
    - request_interval: 5
    - status: 200

query-harbor-notary:
  http.wait_for_successful_query:
    - watch:
      - cmd: harbor
    - name: https://{{ harbor.notary_ingress_host }}.{{ public_domain }}
    - wait_for: 120
    - request_interval: 5
    - status: 401

query-harbor-minio:
  http.wait_for_successful_query:
    - watch:
      - cmd: harbor
      - cmd: harbor-minio-ingress
    - name: https://{{ harbor.core_ingress_host }}-minio.{{ public_domain }}/minio/login

    - wait_for: 120
    - request_interval: 5
    - status: 403