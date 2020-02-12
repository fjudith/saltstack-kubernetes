{%- from "kubernetes/map.jinja" import common with context -%}

include:
  - kubernetes.ingress.nginx.config
  - kubernetes.ingress.nginx.charts
  - kubernetes.ingress.nginx.namespace
  - kubernetes.ingress.nginx.install
  {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
  - kubernetes.ingress.nginx.prometheus
  {%- else %}
  - kubernetes.ingress.nginx.prometheus_embeded
  {%- endif %}
  {%- if common.addons.get('cert_manager', {'enabled': False}).enabled %}
  - kubernetes.ingress.nginx.certificate
  {%- endif -%}
