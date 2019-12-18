{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import master with context -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

include:
  - kubernetes.charts.spinnaker.config
  - kubernetes.charts.spinnaker.charts
  - kubernetes.charts.spinnaker.namespace
  {%- if charts.get('keycloak', {'enabled': False}).enabled %}
  - kubernetes.charts.spinnaker.oauth
  {%- endif %}
  {%- if master.storage.get('rook_minio', {'enabled': False}).enabled %}
  - kubernetes.charts.spinnaker.minio
  {%- endif %}
  - kubernetes.charts.spinnaker.ingress
  - kubernetes.charts.spinnaker.install
  - kubernetes.charts.spinnaker.test
