# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import argo with context %}

argo-repos:
  helm.repo_managed:
    {%- if argo.enabled %}
    - present:
      - name: argo
        url: {{ argo.url }}
    {%- else%}
    - absent:
      - argo
    {%- endif %}

{%- if argo.enabled %}
argo-repos-update:
  helm.repo_updated:
    - name: argo
{%- endif %}
