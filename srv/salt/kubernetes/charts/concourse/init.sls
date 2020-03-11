{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- from "kubernetes/map.jinja" import storage with context -%}

include:
  - kubernetes.charts.concourse.charts
  {%- if charts.get('keycloak', {'enabled': False}).enabled %}
  - kubernetes.charts.concourse.oauth
  {%- endif %}
  - kubernetes.charts.concourse.config
  - kubernetes.charts.concourse.namespace
  {%- if storage.get('minio_operator', {'enabled': False}).enabled %}
  - kubernetes.charts.concourse.minio
  {%- endif %}
  - kubernetes.charts.concourse.install
  - kubernetes.charts.concourse.ingress
  - kubernetes.charts.concourse.test
