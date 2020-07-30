{%- from "kubernetes/map.jinja" import charts with context -%}

include:
  - .config
  {%- if charts.get('keycloak', {'enabled': False}).enabled %}
  - .oauth
  {%- endif %}
  - .charts
  - .namespace
  - .ingress
  - .install
  