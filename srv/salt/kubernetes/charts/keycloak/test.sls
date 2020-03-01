# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import keycloak with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}


query-keycloak:
  http.wait_for_successful_query:
    - name: "https://{{ keycloak.ingress_host }}.{{ public_domain }}/auth/realms/master/"
    - wait_for: 180
    - request_interval: 5
    - status: 200
    - require_in:
      - sls: kubernetes.charts.keycloak-gatekeeper
      {%- if charts.get('concourse', {'enabled': False}).enabled %}
      - sls: kubernetes.charts.concourse
      {%- endif %}
      {%- if charts.get('harbor', {'enabled': False}).enabled %}
      - sls: kubernetes.charts.harbor
      {%- endif %}
      {%- if master.storage.get('keycloak', {'enabled': False}).enabled %}
      - sls: kubernetes.charts.spinnaker
      {%- endif %}
