# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import falco with context %}

falcosecrutiy-repos:
  helm.repo_managed:
    {%- if falco.enabled %}
    - present:
      - name: falcosecurity
        url: {{ falco.url }}
    {%- else%}
    - absent:
      - falcosecurity
    {%- endif %}
