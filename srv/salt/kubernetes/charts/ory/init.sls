# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import ory with context %}
{%- from "kubernetes/map.jinja" import common with context -%}

include:
  - .config
  - .charts
  - .namespace
  - .ingress
  {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
  - .prometheus
  {%- endif %}
  - .install
  {%- if ory.get('kratos', {'enabled': False}).enabled %}
  - .kratos
  {%- endif %}
  {%- if ory.get('oathkeeper', {'enabled': False}).enabled %}
  - .oathkeeper
  {%- endif %}
  - .test
