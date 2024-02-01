{%- from "kubernetes/map.jinja" import charts with context -%}

include:
  - .config
  - .repos
  - .install
  {%- if charts.get('keycloak', {'enabled': False}).enabled %}
  - .finalize
  {% endif %}
