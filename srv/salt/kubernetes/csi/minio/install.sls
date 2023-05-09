# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import minio with context %}

{% set state = 'absent' %}
{% set file_state = 'absent' %}
{% if minio.enabled %}
  {% set state = 'present' %}
  {% set file_state = 'managed' %}
{% endif %}

minio-operator:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/minio
    - name: /srv/kubernetes/charts/minio/values.yaml
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - onchanges:
      - file: /srv/kubernetes/charts/minio/values.yaml
    - name: minio-operator
    {%- if minio.enabled %}
    - chart: minio/operator
    - values: /srv/kubernetes/charts/rook-ceph/values.yaml
    - version: v{{ minio.chart_version }}
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: minio-operator

minio-wait-api:
  cmd.run:
    - watch:
      - helm: minio-operator
    - name: |
        http --check-status --verify false \
        --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
        --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
        https://localhost:6443/apis/{{ minio.api_version }} | grep -niE "{{ minio.api_version }}"
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10
