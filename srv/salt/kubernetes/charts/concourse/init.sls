{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import master with context -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

include:
  - kubernetes.charts.concourse.config
  - kubernetes.charts.concourse.charts
  - kubernetes.charts.concourse.namespace
  {%- if charts.get('keycloak', {'enabled': False}).enabled %}
  - kubernetes.charts.concourse.oauth
  {%- endif %}
  {%- if master.storage.get('rook_minio', {'enabled': False}).enabled %}
  - kubernetes.charts.concourse.minio
  {%- endif %}
  - kubernetes.charts.concourse.ingress
  - kubernetes.charts.concourse.install
  - kubernetes.charts.concourse.test
