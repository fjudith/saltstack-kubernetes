# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import cert_manager with context %}

cert-manager-repos:
  helm.repo_managed:
    {%- if cert_manager.enabled %}
    - present:
      - name: jetstack
        url: {{ cert_manager.url }}
    {%- else %}
    - absent:
      - jetstack
    {%- endif %}
