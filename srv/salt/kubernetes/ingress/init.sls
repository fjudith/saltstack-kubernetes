{%- from "kubernetes/map.jinja" import common with context -%}

include:
  - kubernetes.ingress.metallb
  {%- if common.addons.get('cert_manager', {'enabled': False}).enabled %}
  - kubernetes.ingress.cert-manager
  {%- endif %}
  {%- if common.addons.get('istio', {'enabled': False}).enabled %}
  - kubernetes.ingress.istio
  {%- endif %}
  {%- if common.addons.get('contour', {'enabled': False}).enabled %}
  - kubernetes.ingress.contour
  {%- endif %}
