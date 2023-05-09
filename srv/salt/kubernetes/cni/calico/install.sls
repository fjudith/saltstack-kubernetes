# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import calico with context %}

{% set state = 'absent' %}
{% set file_state = 'absent' %}
{% if calico.enabled %}
  {% set state = 'present' %}
  {% set file_state = 'managed' %}
{% endif %}

calico:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/calico
    - name: /srv/kubernetes/charts/calico/values.yaml
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - watch:
      - file: /srv/kubernetes/charts/calico/values.yaml
    - name: calico
    {%- if calico.enabled %}
    - chart: projectcalico/tigera-operator
    - values: /srv/kubernetes/charts/calico/values.yaml
    - version: v{{ calico.chart_version }}
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: tigera-operator