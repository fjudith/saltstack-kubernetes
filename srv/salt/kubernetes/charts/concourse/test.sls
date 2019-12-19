{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

query-concourse-web:
  http.wait_for_successful_query:
    - watch:
      - cmd: concourse
      - cmd: concourse-ingress
    - name: https://{{ charts.concourse.ingress_host }}.{{ public_domain }}
    # - match: DaemonSet
    - wait_for: 120
    - request_interval: 5
    - status: 200

query-concourse-minio:
  http.wait_for_successful_query:
    - watch:
      - cmd: concourse-minio
      - cmd: concourse-ingress
    - name: https://{{ charts.concourse.ingress_host }}-minio.{{ public_domain }}/minio/login
    # - match: DaemonSet
    - wait_for: 120
    - request_interval: 5
    - status: 403