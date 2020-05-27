{%- from "kubernetes/map.jinja" import common with context -%}

include:
  - kubernetes.addons.default-cluster-role-binding
  {%- if common.addons.dns.get('coredns', {'enabled': False}).enabled %}
  - kubernetes.addons.coredns
  {%- endif %}
  {%- if common.addons.dns.get('autoscaler', {'enabled': False}).enabled %}
  - kubernetes.addons.dns-horizontal-autoscaler
  {%- endif %}
  {%- if common.addons.get('dashboard', {'enabled': False}).enabled %}
  - kubernetes.addons.kubernetes-dashboard
  {%- endif %}
  {%- if common.addons.get('helm', {'enabled': False}).enabled %}
  - kubernetes.addons.helm
  {%- endif %}
  {%- if common.addons.get('npd', {'enabled': False}).enabled %}
  - kubernetes.addons.node-problem-detector
  {%- endif %}
  {%- if common.addons.get('heapster_influxdb', {'enabled': False}).enabled %}
  - kubernetes.addons.heapster-influxdb
  {%- endif %}
  {%- if common.addons.get('fluentd_elasticsearch', {'enabled': False}).enabled %}
  - kubernetes.addons.fluentd-elasticsearch
  {%- endif %}
  {%- if common.addons.get('weave_scope', {'enabled': False}).enabled %}
  - kubernetes.addons.weave-scope
  {%- endif %}
  {%- if common.addons.get('nats_operator', {'enabled': False}).enabled %}
  - kubernetes.addons.nats-operator
  {%- endif %}
  {%- if common.addons.get('kubeless', {'enabled': False}).enabled %}
  - kubernetes.addons.kubeless
  {%- endif %}
  {%- if common.addons.get('httpbin', {'enabled': False}).enabled %}
  - kubernetes.addons.httpbin
  {%- endif %}
  {%- if common.addons.get('descheduler', {'enabled': False}).enabled %}
  - kubernetes.addons.descheduler
  {%- endif %}
  {%- if common.addons.get('kube_scan', {'enabled': False}).enabled %}
  - kubernetes.addons.kube-scan
  {%- endif %}