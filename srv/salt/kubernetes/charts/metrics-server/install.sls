# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import metrics_server with context %}

{% set state = 'absent' %}
{% set file_state = 'absent' %}
{% if metrics_server.enabled %}
  {% set state = 'present' %}
  {% set file_state = 'managed' %}
{% endif %}

metrics-server:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/metrics-server
    - name: /srv/kubernetes/charts/metrics-server/values.yaml
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
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