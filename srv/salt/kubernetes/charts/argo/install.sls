# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import argo with context %}
{%- from "kubernetes/map.jinja" import storage with context -%}

{% set state = 'absent' %}
{% set file_state = 'absent' %}
{% if argo.cd.enabled %}
  {% set state = 'present' %}
  {% set file_state = 'managed' %}
{% endif %}

argo-cd:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/argo
    - name: /srv/kubernetes/charts/argo/cd-values.yaml
    - source: salt://{{ tpldir }}/templates/cd-values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - watch:
      - file: /srv/kubernetes/charts/argo/cd-values.yaml
    - name: argo-cd
    {%- if argo.enabled %}
    - chart: argo/argo-cd
    - values: /srv/kubernetes/charts/argo/cd-values.yaml
    - version: {{ argo.cd.chart_version }}
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: argo-cd

{%- if storage.get('minio', {'enabled': False}).enabled %}
argo-workflows-minio:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/argo
    - name: /srv/kubernetes/charts/argo/workflows-minio-values.yaml
    - source: salt://{{ tpldir }}/templates/workflows-minio-values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - watch:
      - file: /srv/kubernetes/charts/argo/workflows-minio-values.yaml
    - name: argo-workflows-minio
    {%- if argo.enabled %}
    - chart: minio/tenant
    - values: /srv/kubernetes/charts/argo/workflows-minio-values.yaml
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: argo-workflows
{%- endif %}

argo-workflows:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/argo
    - name: /srv/kubernetes/charts/argo/workflows-values.yaml
    - source: salt://{{ tpldir }}/templates/workflows-values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - watch:
      - file: /srv/kubernetes/charts/argo/workflows-values.yaml
    - name: argo-workflows
    {%- if argo.enabled %}
    - chart: argo/argo-workflows
    - values: /srv/kubernetes/charts/argo/workflows-values.yaml
    - version: {{ argo.workflows.chart_version }}
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: argo-workflows

argo-events:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/argo
    - name: /srv/kubernetes/charts/argo/events-values.yaml
    - source: salt://{{ tpldir }}/templates/events-values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - watch:
      - file: /srv/kubernetes/charts/argo/events-values.yaml
    - name: argo-events
    {%- if argo.enabled %}
    - chart: argo/argo-events
    - values: /srv/kubernetes/charts/argo/events-values.yaml
    - version: {{ argo.events.chart_version }}
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: argo-events