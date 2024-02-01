# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import harbor with context %}
{%- from "kubernetes/map.jinja" import storage with context -%}
{%- from "kubernetes/map.jinja" import common with context -%}

{% set state = 'absent' %}
{% set file_state = 'absent' %}
{% if harbor.enabled %}
  {% set state = 'present' %}
  {% set file_state = 'managed' %}
{% endif %}

{%- if storage.get('minio', {'enabled': False}).enabled %}
harbor-minio:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/harbor
    - name: /srv/kubernetes/charts/harbor/minio-values.yaml
    - source: salt://{{ tpldir }}/templates/minio-values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - watch:
      - file: /srv/kubernetes/charts/harbor/minio-values.yaml
    - name: harbor-minio
    {%- if harbor.enabled %}
    - chart: minio/tenant
    - values: /srv/kubernetes/charts/harbor/minio-values.yaml
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: harbor
{%- endif %}

{%- if common.addons.get('cert_manager', {'enabled': False}).enabled %}
harbor-cert:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/harbor
    - name: /srv/kubernetes/manifests/harbor/certificates.yaml
    - source: salt://{{ tpldir }}/templates/certificates.yaml.j2
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}
  cmd.run:
    - onchanges:
      - file: /srv/kubernetes/manifests/harbor/certificates.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/harbor/certificates.yaml
{%- endif %}

harbor:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/harbor
    - name: /srv/kubernetes/charts/harbor/values.yaml
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - watch:
      - file: /srv/kubernetes/charts/harbor/values.yaml
    - name: harbor
    {%- if harbor.enabled %}
    - chart: harbor/harbor
    - values: /srv/kubernetes/charts/harbor/values.yaml
    - version: {{ harbor.chart_version }}
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: harbor
