# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import concourse with context %}
{%- from "kubernetes/map.jinja" import storage with context -%}

{% set state = 'absent' %}
{% set file_state = 'absent' %}
{% if concourse.enabled %}
  {% set state = 'present' %}
  {% set file_state = 'managed' %}
{% endif %}

{%- if storage.get('minio', {'enabled': False}).enabled %}
concourse-minio:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/concourse
    - name: /srv/kubernetes/charts/concourse/minio-values.yaml
    - source: salt://{{ tpldir }}/templates/minio-values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - watch:
      - file: /srv/kubernetes/charts/concourse/minio-values.yaml
    - name: concourse-minio
    {%- if concourse.enabled %}
    - chart: minio/tenant
    - values: /srv/kubernetes/charts/concourse/minio-values.yaml
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: concourse
{%- endif %}

concourse:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/concourse
    - name: /srv/kubernetes/charts/concourse/values.yaml
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - watch:
      - file: /srv/kubernetes/charts/concourse/values.yaml
    - name: concourse
    {%- if concourse.enabled %}
    - chart: concourse/concourse
    - values: /srv/kubernetes/charts/concourse/values.yaml
    - version: {{ concourse.chart_version }}
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: concourse
