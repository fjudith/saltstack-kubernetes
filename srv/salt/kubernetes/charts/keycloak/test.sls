# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import keycloak with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

query-keycloak:
  http.wait_for_successful_query:
    - name: "https://{{ keycloak.ingress_host }}.{{ public_domain }}/auth/realms/master/"
    - wait_for: 180
    - request_interval: 5
    - status: 200
    - require_in:
      - sls: kubernetes.charts.keycloak-gatekeeper.init
      {%- if charts.get('concourse', {'enabled': False}).enabled %}
      - sls: kubernetes.charts.concourse.init
      {%- endif %}
      {%- if charts.get('harbor', {'enabled': False}).enabled %}
      - sls: kubernetes.charts.harbor.init
      {%- endif %}
      {%- if charts.get('spinnaker', {'enabled': False}).enabled %}
      - sls: kubernetes.charts.spinnaker.init
      {%- endif %}
      {%- if charts.get('proxyinjector', {'enabled': False}).enabled %}
      - sls: kubernetes.charts.proxyinjector.init
      {%- endif %}
      {%- if charts.get('openfaas', {'enabled': False}).enabled %}
      - sls: kubernetes.charts.openfaas.init
      {%- endif %}
      {%- if charts.get('argo', {'enabled': False}).enabled %}
      - sls: kubernetes.charts.argo.init
      {%- endif %}
      {%- if charts.get('argo_cd', {'enabled': False}).enabled %}
      - sls: kubernetes.charts.argo_cd.init
      {%- endif %}
      {%- if charts.get('keycloak_gatekeeper', {'enabled': False}).enabled %}
      - sls: kubernetes.charts.keycloak_gatekeeper.init
      {%- endif %}
