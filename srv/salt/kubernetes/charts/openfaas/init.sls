{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

include:
  - kubernetes.charts.openfaas.charts
  {%- if charts.get('keycloak', {'enabled': False}).enabled %}
  - kubernetes.charts.openfaas.oauth
  {%- endif %}
  - kubernetes.charts.openfaas.config
  - kubernetes.charts.openfaas.namespace
  - kubernetes.charts.openfaas.install
  - kubernetes.charts.openfaas.ingress
  {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
  - kubernetes.charts.openfaas.prometheus
  {%- endif %}
  - kubernetes.charts.openfaas.test
