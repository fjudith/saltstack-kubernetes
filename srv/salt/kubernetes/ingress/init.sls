{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}

include:
{%- if common.addons.get('cert_manager', {'enabled': False}).enabled %}
  - kubernetes.ingress.cert-manager
{%- endif -%}
{%- if common.addons.get('ingress_nginx', {'enabled': False}).enabled %}
  - kubernetes.ingress.ingress-nginx
{%- endif -%}
{%- if common.addons.get('ingress_traefik', {'enabled': False}).enabled %}
  - kubernetes.ingress.traefik
{%- endif -%}
{%- if common.addons.get('ingress_istio', {'enabled': False}).enabled %}
  - kubernetes.ingress.istio
{%- endif -%}