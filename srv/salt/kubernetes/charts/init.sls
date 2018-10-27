{%- from "kubernetes/map.jinja" import charts with context -%}

include:
  - kubernetes.charts.keycloack
{%- if charts.get('mailhog', {'enabled': False}).enabled %}
  - kubernetes.charts.mailhog
{%- endif -%}
{%- if charts.get('spinnaker', {'enabled': False}).enabled %}
  - kubernetes.charts.spinnaker
{%- endif -%}