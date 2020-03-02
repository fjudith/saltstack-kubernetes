
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import storage with context -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

include:
  - kubernetes.charts.keycloak-gatekeeper.config
  - kubernetes.charts.keycloak-gatekeeper.charts
  - kubernetes.charts.keycloak-gatekeeper.install
  {%- if common.addons.get('dashboard', {'enabled': False}).enabled %}
  - kubernetes.charts.keycloak-gatekeeper.kubernetes-dashboard
  {%- endif %}
  {%- if common.addons.get('weave_scope', {'enabled': False}).enabled %}
  - kubernetes.charts.keycloak-gatekeeper.weave-scope
  {%- endif %}
  {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
  - kubernetes.charts.keycloak-gatekeeper.kube-prometheus
  {%- endif %}
  {%- if storage.get('rook_ceph', {'enabled': False}).enabled %}
  - kubernetes.charts.keycloak-gatekeeper.rook-ceph
  {%- endif %}
  - kubernetes.charts.keycloak-gatekeeper.test