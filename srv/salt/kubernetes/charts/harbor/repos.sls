# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import harbor with context %}

harbor-repos:
  helm.repo_managed:
    {%- if harbor.enabled %}
    - present:
      - name: harbor
        url: {{ harbor.url }}
        repo_update: True
    {%- else%}
    - absent:
      - harbor
    {%- endif %}
