{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import storage with context -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- set keycloak_password = charts.get('keycloak', {}).get('password') -%}

{% if common.addons.get('dashboard', {'enabled': False}).enabled %}
query-kgk-kubernetes-dashboard:
  http.wait_for_successful_query:
    - watch:
      - cmd: keycloak-kubernetes-dashboard
    - name: https://{{ common.addons.dashboard.ingress_host }}.{{ public_domain }}
    - wait_for: 120
    - request_interval: 5
    - status: 200
{% endif %}

{% if common.addons.get('weave_scope', {'enabled': False}).enabled %}
query-kgk-weave-scope:
  http.wait_for_successful_query:
    - watch:
      - cmd: keycloak-weave-scope
    - name: https://{{ common.addons.weave_scope.ingress_host }}.{{ public_domain }}
    - wait_for: 120
    - request_interval: 5
    - status: 200
{% endif %}

{% if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
{# query-kgk-grafana:
  http.wait_for_successful_query:
    - watch:
      - cmd: keycloak-grafana
    - name: https://{{ common.addons.kube_prometheus.grafana_ingress_host }}.{{ public_domain }}
    - wait_for: 120
    - request_interval: 5
    - status: 200 #}

query-kgk-prometheus:
  http.wait_for_successful_query:
    - watch:
      - cmd: keycloak-prometheus
    - name: https://{{ common.addons.kube_prometheus.prometheus_ingress_host }}.{{ public_domain }}
    - wait_for: 120
    - request_interval: 5
    - status: 200

query-kgk-alertmanager:
  http.wait_for_successful_query:
    - watch:
      - cmd: keycloak-alertmanager
    - name: https://{{ common.addons.kube_prometheus.alertmanager_ingress_host }}.{{ public_domain }}
    - wait_for: 120
    - request_interval: 5
    - status: 200
{% endif %}

{% if storage.get('rook_ceph', {'enabled': False}).enabled %}
query-kgk-rook-ceph:
  http.wait_for_successful_query:
    - watch:
      - cmd: keycloak-rook-ceph
    - name: https://{{ storage.rook_ceph.ingress_host }}.{{ public_domain }}
    - wait_for: 120
    - request_interval: 5
    - status: 200
{% endif %}