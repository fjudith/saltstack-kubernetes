# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import ory with context %}
include:
  - .config
  - .charts
  - .namespace
  - .ingress
  - .install
  {%- if ory.get('kratos', {'enabled': False}).enabled %}
  - .kratos
  {%- endif %}