# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import rook_ceph with context %}

{% set state = 'absent' %}
{% set file_state = 'absent' %}
{% if rook_ceph.enabled %}
  {% set state = 'present' %}
  {% set file_state = 'managed' %}
{% endif %}

rook-ceph:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/rook-ceph
    - name: /srv/kubernetes/charts/rook-ceph/values.yaml
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - watch:
      - file: /srv/kubernetes/charts/rook-ceph/values.yaml
    - name: rook-ceph
    {%- if rook_ceph.enabled %}
    - chart: rook-release/rook-ceph
    - values: /srv/kubernetes/charts/rook-ceph/values.yaml
    - version: v{{ rook_ceph.chart_version }}
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: rook-ceph

rook-ceph-wait-api:
  cmd.run:
    - require:
      - helm: rook-ceph 
    - name: |
        http --check-status --verify false \
        --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
        --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
        https://localhost:6443/apis/{{ rook_ceph.api_version }} | grep -niE "{{ rook_ceph.api_version }}"
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10

rook-ceph-cluster:
  file.{{ file_state }}:
    - require:
      - cmd: rook-ceph-wait-api
      - file:  /srv/kubernetes/charts/rook-ceph
    - name: /srv/kubernetes/charts/rook-ceph/cluster-values.yaml
    - source: salt://{{ tpldir }}/templates/cluster-values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - watch:
      - file: /srv/kubernetes/charts/rook-ceph/cluster-values.yaml
    - name: rook-ceph-cluster
    {%- if rook_ceph.enabled %}
    - chart: rook-release/rook-ceph-cluster
    - values: /srv/kubernetes/charts/rook-ceph/cluster-values.yaml
    - version: v{{ rook_ceph.chart_version }}
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: rook-ceph-cluster