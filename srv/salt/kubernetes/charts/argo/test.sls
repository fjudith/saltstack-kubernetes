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

argo-minio-bucket:
  cmd.run:
    - require:
      - http: query-argo-minio
    - runas: root
    - timeout: 180
    - env:
      - MC_HOST_argo: "https://{{ argo.s3.accesskey }}:{{ argo.s3.secretkey }}@{{ argo.ingress_host }}-minio.{{ public_domain }}"
    - name: |
        /usr/local/bin/mc mb argo/{{ argo.s3.bucket }} --ignore-existing

test-workflow:
  cmd.run:
    - require:
      - http: query-argo-minio
      - cmd: argo-minio-bucket
    - runas: root
    - name: |
        argo submit -n argo --watch https://raw.githubusercontent.com/argoproj/argo/master/examples/hello-world.yaml
        argo list -n argo
        argo get -n argo @latest
        argo logs -n argo @latest