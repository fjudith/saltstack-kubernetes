# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import falco with context %}

{% set state = 'absent' %}
{% set file_state = 'absent' %}
{% if falco.enabled %}
  {% set state = 'present' %}
  {% set file_state = 'managed' %}
{% endif %}

falco:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/falco
    - name: /srv/kubernetes/charts/falco/values.yaml
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - onchanges:
      - file: /srv/kubernetes/charts/falco/values.yaml
    - name: metrics-server
    {%- if falco.enabled %}
    - chart: falcosecurity/falco
    - values: /srv/kubernetes/charts/falco/values.yaml
    - version: {{ falco.chart_version }}
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: falco