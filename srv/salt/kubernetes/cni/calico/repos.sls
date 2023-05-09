# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import calico with context %}

calico-repos:
  helm.repo_managed:
    {%- if calico.enabled %}
    - present:
      - name: projectcalico
        url: {{ calico.url }}
    {%- else%}
    - absent:
      - projectcalico
    {%- endif %}
