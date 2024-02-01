# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import helm with context %}

helm-stable-repos:
  helm.repo_managed:
    {%- if helm.enabled %}
    - present:
      - name: stable
        url: {{ helm.url }}
    {%- else%}
    - absent:
      - stable
    {%- endif %}