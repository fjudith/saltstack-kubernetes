# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{%- from tpldir ~ "/map.jinja" import containerd with context %}


{% set pkgState = 'absent' %}
{% if containerd.enabled %}
  {% set pkgState = 'installed' %}
{% endif %}

containerd:
  pkg.{{ pkgState }}:
    - name: containerd.io
    - version: {{ containerd.version }}-1