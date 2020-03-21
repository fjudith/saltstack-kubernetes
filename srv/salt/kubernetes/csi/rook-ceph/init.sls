{%- from "kubernetes/map.jinja" import common with context -%}

include:
  - .config
  - .namespace
  - .install
  - .pool
  - .object
  - .filesystem
  - .toolbox
  - .ingress
  {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
  - .prometheus
  {%- else %}
  - .prometheus_embeded
  {%- endif %}
  - .storageclass