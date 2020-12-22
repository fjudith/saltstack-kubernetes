# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import gitea with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- from "kubernetes/map.jinja" import storage with context -%}
{%- from "kubernetes/map.jinja" import common with context -%}

include:
  - .charts
  - .config
  - .namespace
  {%- if charts.get('keycloak', {'enabled': False}).enabled %}
  - .oauth
  {%- endif %}
  {%- if storage.get('minio_operator', {'enabled': False}).enabled %}
  - .minio
  {%- endif %}
  - .install
  - .ingress
  {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
  - .prometheus
  {%- endif %}
  - .test
