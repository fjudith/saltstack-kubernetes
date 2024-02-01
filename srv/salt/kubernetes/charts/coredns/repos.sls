# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import coredns with context %}

coredns-repos:
  helm.repo_managed:
    {%- if coredns.enabled %}
    - present:
      - name: coredns
        url: {{ coredns.url }}
    {%- else %}
    - absent:
      - coredns
    {%- endif %}

{%- if coredns.enabled %}
coredns-repos-update:
  helm.repo_updated:
    - name: coredns
{%- endif %}
