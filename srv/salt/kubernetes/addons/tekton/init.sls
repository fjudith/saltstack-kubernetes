{%- from "kubernetes/map.jinja" import common with context -%}

include:
  - .repo
  - .osprep
  - .config
  - .namespace
  # {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
  # - .prometheus
  # {%- endif %}
  - .install
  - .ingress
  - .test
