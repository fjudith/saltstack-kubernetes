{%- from "kubernetes/map.jinja" import common with context -%}

include:
  - kubernetes.addons.default-cluster-role-binding
  {%- if common.addons.dns.get('autoscaler', {'enabled': False}).enabled %}
  - kubernetes.addons.dns-horizontal-autoscaler
  {%- endif %}
  {%- if common.addons.dns.get('open_policy_agent', {'enabled': False}).enabled %}
  - kubernetes.addons.open-policy-agent
  {%- endif %}
  {%- if common.addons.get('helm', {'enabled': False}).enabled %}
  - kubernetes.addons.helm
  {%- endif %}
  {%- if common.addons.get('npd', {'enabled': False}).enabled %}
  - kubernetes.addons.node-problem-detector
  {%- endif %}
  {%- if common.addons.get('weave_scope', {'enabled': False}).enabled %}
  - kubernetes.addons.weave-scope
  {%- endif %}
  {%- if common.addons.get('nats_operator', {'enabled': False}).enabled %}
  - kubernetes.addons.nats-operator
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
  {%- if common.addons.get('rook_cockroachdb', {'enabled': False}).enabled %}
  - kubernetes.addons.rook-cockroachdb
  {%- endif %}
  {%- if common.addons.get('rook_yugabytedb', {'enabled': False}).enabled %}
  - kubernetes.addons.rook-yugabytedb
  {%- endif %}