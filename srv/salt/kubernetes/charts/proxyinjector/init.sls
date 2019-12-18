{%- from "kubernetes/map.jinja" import charts with context -%}

include:
  - kubernetes.charts.proxyinjector.config
  - kubernetes.charts.proxyinjector.charts
  {%- if charts.get('keycloak', {'enabled': False}).enabled %}
  - kubernetes.charts.proxyinjector.oauth
  {%- endif %}
  - kubernetes.charts.proxyinjector.namespace
  - kubernetes.charts.proxyinjector.install
  - kubernetes.charts.proxyinjector.test
