# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import nats_operator with context %}

nats-repos:
  helm.repo_managed:
    {%- if nats_operator.enabled %}
    - present:
      - name: nats
        url: {{ nats_operator.url }}
    {%- else%}
    - absent:
      - nats
    {%- endif %}
