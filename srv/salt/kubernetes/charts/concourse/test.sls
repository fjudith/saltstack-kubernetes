# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import concourse with context %}
{%- set public_domain = pillar['public-domain'] -%}

query-concourse-web:
  http.wait_for_successful_query:
    - watch:
      - cmd: concourse
      - cmd: concourse-ingress
    - name: https://{{ concourse.ingress_host }}.{{ public_domain }}
    - wait_for: 120
    - request_interval: 5
    - status: 200

query-concourse-minio:
  http.wait_for_successful_query:
    - watch:
      - cmd: concourse-minio
      - cmd: concourse-ingress
    - name: https://{{ concourse.ingress_host }}-minio.{{ public_domain }}/minio/health/ready
    - wait_for: 120
    - request_interval: 5
    - status: 200