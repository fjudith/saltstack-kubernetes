# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import kube_prometheus with context %}

kube-prometheus-repos:
  helm.repo_managed:
    {%- if kube_prometheus.enabled %}
    - present:
      - name: prometheus-community
        url: {{ kube_prometheus.url }}
    {%- else%}
    - absent:
      - prometheus-community
    {%- endif %}
