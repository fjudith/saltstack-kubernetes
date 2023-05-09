{%- from "kubernetes/map.jinja" import common with context -%}

include:
  - .config
  - .repos
  - .install
  {%- if common.addons.get('cert_manager', {'enabled': False}).enabled %}
  - .certificate
  {%- endif%}