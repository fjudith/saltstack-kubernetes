{%- from "kubernetes/map.jinja" import common with context -%}

include:
  - kubernetes.ingress.nginx.config
  - kubernetes.ingress.nginx.install
  {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
  - kubernetes.ingress.nginx.prometheus
  {%- endif %}
