{%- from "kubernetes/map.jinja" import common with context -%}

include:
  - .config
  - .namespace
  - .install
  - .ingress
  {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
  - .prometheus
  {%- endif %}
  - .test