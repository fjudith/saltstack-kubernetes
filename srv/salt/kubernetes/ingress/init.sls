{%- from "kubernetes/map.jinja" import common with context -%}

include:
  - kubernetes.ingress.metallb
  {%- if common.addons.get('cert_manager', {'enabled': False}).enabled %}
  - kubernetes.ingress.cert-manager
  {%- endif %}
  {%- if common.addons.get('nginx', {'enabled': False}).enabled %}
  - kubernetes.ingress.nginx
  {%- endif %}
  {%- if common.addons.get('traefik', {'enabled': False}).enabled %}
  - kubernetes.ingress.traefik
  {%- endif %}
  {%- if common.addons.get('istio', {'enabled': False}).enabled %}
  - kubernetes.ingress.istio
  {%- endif %}