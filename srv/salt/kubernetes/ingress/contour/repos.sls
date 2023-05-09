# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import contour with context %}

contour-repos:
  helm.repo_managed:
    {%- if contour.enabled %}
    - present:
      - name: bitnami
        url: {{ contour.url }}
    {%- else%}
    - absent:
      - bitnami
    {%- endif %}
