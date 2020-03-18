# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{%- from tpldir ~ "/map.jinja" import docker with context %}


{% set pkgState = 'absent' %}
{% if docker.enabled %}
  {% set pkgState = 'installed' %}
{% endif %}

docker-ce:
  pkg.{{ pkgState }}:
    - version: 5:{{ docker.version }}~3-0~ubuntu-{{ grains["oscodename"] }}