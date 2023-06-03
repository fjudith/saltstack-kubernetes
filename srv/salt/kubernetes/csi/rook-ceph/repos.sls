# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import rook_ceph with context %}

rook-repos:
  helm.repo_managed:
    {%- if rook_ceph.enabled %}
    - present:
      - name: rook-release
        url: {{ rook_ceph.url }}
    {%- else %}
    - absent:
      - rook-release
    {%- endif %}
