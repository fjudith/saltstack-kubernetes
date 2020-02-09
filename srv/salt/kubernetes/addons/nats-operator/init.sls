{%- from "kubernetes/map.jinja" import common with context -%}

include:
  - kubernetes.addons.nats-operator.config
  - kubernetes.addons.nats-operator.namespace
  - kubernetes.addons.nats-operator.install
  {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
  - kubernetes.addons.nats-operator.prometheus
  {%- endif -%}