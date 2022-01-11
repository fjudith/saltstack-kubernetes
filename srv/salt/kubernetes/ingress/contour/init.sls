{%- from "kubernetes/map.jinja" import common with context -%}

include:
  - .config
  - .charts
  - .namespace
  - .install
  {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
  - .prometheus
  {%- endif%}
  {# - .patch #}
  {%- if common.addons.get('cert_manager', {'enabled': False}).enabled %}
  - .certificate
  {%- endif%}
