# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import concourse with context %}

concourse-repos:
  helm.repo_managed:
    {%- if concourse.enabled %}
    - present:
      - name: concourse
        url: {{ concourse.url }}
    {%- else%}
    - absent:
      - concourse
    {%- endif %}
