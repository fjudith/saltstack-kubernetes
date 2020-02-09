{%- from "kubernetes/map.jinja" import common with context -%}

include:
  - kubernetes.ingress.cert-manager.config
  - kubernetes.ingress.cert-manager.charts
  - kubernetes.ingress.cert-manager.namespace
  - kubernetes.ingress.cert-manager.install
  {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
  - kubernetes.ingress.cert-manager.prometheus
  {%- endif -%}