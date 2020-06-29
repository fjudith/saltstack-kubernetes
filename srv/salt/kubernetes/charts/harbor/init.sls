{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- from "kubernetes/map.jinja" import storage with context -%}

include:
  - .config
  - .charts
  - .namespace
  {%- if charts.get('keycloak', {'enabled': False}).enabled %}
  - .oauth
  {%- endif %}
  {%- if storage.get('minio_operator', {'enabled': False}).enabled %}
  - .minio
  {%- endif %}
  - .install
  - .ingress
  - .test
  - .finalize
