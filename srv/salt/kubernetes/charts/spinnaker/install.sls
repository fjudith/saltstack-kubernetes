# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import spinnaker with context %}
{%- from "kubernetes/map.jinja" import storage with context -%}

{% set state = 'absent' %}
{% set file_state = 'absent' %}
{% if spinnaker.enabled %}
  {% set state = 'present' %}
  {% set file_state = 'managed' %}
{% endif %}

{%- if storage.get('minio', {'enabled': False}).enabled %}
spinnaker-minio:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/spinnaker
    - name: /srv/kubernetes/charts/spinnaker/minio-values.yaml
    - source: salt://{{ tpldir }}/templates/minio-values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - watch:
      - file: /srv/kubernetes/charts/spinnaker/minio-values.yaml
    - name: spinnaker-minio
    {%- if spinnaker.enabled %}
    - chart: minio/tenant
    - values: /srv/kubernetes/charts/spinnaker/minio-values.yaml
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: spinnaker
{%- endif %}

spinnaker:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/spinnaker
    - name: /srv/kubernetes/charts/spinnaker/values.yaml
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - onchanges:
      - file: /srv/kubernetes/charts/spinnaker/values.yaml
    - name: spinnaker
    {%- if spinnaker.enabled %}
    - chart: spinnaker/spinnaker
    - values: /srv/kubernetes/charts/spinnaker/values.yaml
    - version: {{ spinnaker.chart_version }}
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: spinnaker