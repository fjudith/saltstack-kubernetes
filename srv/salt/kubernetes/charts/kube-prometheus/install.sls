# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import kube_prometheus with context %}

{% set state = 'absent' %}
{% set file_state = 'absent' %}
{% if kube_prometheus.enabled %}
  {% set state = 'present' %}
  {% set file_state = 'managed' %}
{% endif %}

kube-prometheus:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/kube-prometheus
    - name: /srv/kubernetes/charts/kube-prometheus/values.yaml
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - watch:
      - file: /srv/kubernetes/charts/kube-prometheus/values.yaml
    - name: kube-prometheus
    {%- if kube_prometheus.enabled %}
    - chart: prometheus-community/kube-prometheus-stack
    - values: /srv/kubernetes/charts/kube-prometheus/values.yaml
    - version: {{ kube_prometheus.chart_version }}
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: monitoring

kube-prometheus-pushgateway:
  helm.release_{{ state }}:
    - name: kube-prometheus-pushgateway
    {%- if kube_prometheus.enabled %}
    - chart: prometheus-community/prometheus-pushgateway
    # - version: {{ kube_prometheus.chart_version }}
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: monitoring