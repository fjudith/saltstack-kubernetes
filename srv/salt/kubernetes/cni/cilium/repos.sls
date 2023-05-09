# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import cilium with context %}

cilium-repos:
  helm.repo_managed:
    {%- if cilium.enabled %}
    - present:
      - name: cilium
        url: {{ cilium.url }}
    {%- else%}
    - absent:
      - cilium
    {%- endif %}
