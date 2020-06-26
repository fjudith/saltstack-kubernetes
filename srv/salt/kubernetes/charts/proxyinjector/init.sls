{%- from "kubernetes/map.jinja" import charts with context -%}

include:
  - .config
  - .charts
  {%- if charts.get('keycloak', {'enabled': False}).enabled %}
  - .oauth
  {%- endif %}
  - .namespace
  - .install
  - .ingress
  - .test
