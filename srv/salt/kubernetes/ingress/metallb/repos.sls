# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import metallb with context %}

metallb-repos:
  helm.repo_managed:
    {%- if metallb.enabled %}
    - present:
      - name: metallb
        url: {{ metallb.url }}
    {%- else%}
    - absent:
      - metallb
    {%- endif %}
