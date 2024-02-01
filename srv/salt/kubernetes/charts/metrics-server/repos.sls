# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import metrics_server with context %}

metrics-server-repos:
  helm.repo_managed:
    {%- if metrics_server.enabled %}
    - present:
      - name: metrics-server
        url: {{ metrics_server.url }}
    {%- else%}
    - absent:
      - metrics-server
    {%- endif %}
