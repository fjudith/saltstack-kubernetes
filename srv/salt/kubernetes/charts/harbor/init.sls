{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

include:
  - kubernetes.charts.harbor.config
  - kubernetes.charts.harbor.charts
  - kubernetes.charts.harbor.namespace
  {%- if charts.get('keycloak', {'enabled': False}).enabled %}
  - kubernetes.charts.harbor.oauth
  {%- endif %}
  {%- if charts.get('minio_operator', {'enabled': False}).enabled %}
  - kubernetes.charts.harbor.minio
  {%- endif %}
  - kubernetes.charts.harbor.ingress
  - kubernetes.charts.harbor.install
  - kubernetes.charts.harbor.test
