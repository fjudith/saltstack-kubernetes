# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import jenkins with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

query-jenkins:
  http.wait_for_successful_query:
    - name: "https://{{ jenkins.ingress_host }}.{{ public_domain }}/"
    - wait_for: 180
    - request_interval: 5
    - status: 200
