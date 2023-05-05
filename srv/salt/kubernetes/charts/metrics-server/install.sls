# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import metrics_server with context %}

{% set state = 'absent' %}
{% if metrics_server.enabled %}
  {% set state = 'present' %}
{% endif %}

metrics-server:
  helm.release_{{ state }}:
    - onchanges:
      - file: /srv/kubernetes/charts/metrics-server/values.yaml
    - name: metrics-server
    {%- if metrics_server.enabled %}
    - chart: metrics-server/metrics-server
    - values: /srv/kubernetes/charts/metrics-server/values.yaml
    - version: {{ metrics_server.chart_version }}
    {%- endif %}
    - namespace: kube-system