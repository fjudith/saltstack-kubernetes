# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import coredns with context %}

{% set state = 'absent' %}
{% if coredns.enabled %}
  {% set state = 'present' %}
{% endif %}

coredns:
  helm.release_{{ state }}:
    - onchanges:
      - file: /srv/kubernetes/charts/coredns/values.yaml
    - name: coredns
    {%- if coredns.enabled %}
    - chart: coredns/coredns
    - values: /srv/kubernetes/charts/coredns/values.yaml
    - version: {{ coredns.chart_version }}
    {%- endif %}
    - namespace: kube-system