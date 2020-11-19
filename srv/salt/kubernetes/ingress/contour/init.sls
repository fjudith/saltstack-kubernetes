{%- from "kubernetes/map.jinja" import common with context -%}

include:
  - .config
  - .charts
  - .namespace
  - .install
  {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
  - kubernetes.ingress.nginx.prometheus
  {%- endif -%}
  {%- if common.addons.get('cert_manager', {'enabled': False}).enabled %}
  - kubernetes.ingress.nginx.certificate
  {%- endif -%}
