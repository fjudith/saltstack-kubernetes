# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import spinnaker with context %}

spinnaker-repos:
  helm.repo_managed:
    {%- if spinnaker.enabled %}
    - present:
      - name: spinnaker
        url: {{ spinnaker.url }}
    {%- else%}
    - absent:
      - spinnaker
    {%- endif %}
