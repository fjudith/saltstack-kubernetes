# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import minio with context %}

minio-repos:
  helm.repo_managed:
    {%- if minio.enabled %}
    - present:
      - name: minio
        url: {{ minio.url }}
    {%- else%}
    - absent:
      - minio
    {%- endif %}
