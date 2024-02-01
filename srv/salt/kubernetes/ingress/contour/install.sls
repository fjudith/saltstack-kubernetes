# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import contour with context %}

{% set state = 'absent' %}
{% if contour.enabled %}
  {% set state = 'present' %}
{% endif %}

contour:
  helm.release_{{ state }}:
    - watch:
      - file: /srv/kubernetes/charts/contour/values.yaml
    - name: contour
    {%- if contour.enabled %}
    - chart: bitnami/contour
    - values: /srv/kubernetes/charts/contour/values.yaml
    - version: v{{ contour.chart_version }}
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: projectcontour

contour-wait-api:
  cmd.run:
    - name: |
        http --check-status --verify false \
        --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
        --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
        https://localhost:6443/apis/{{ contour.api_version }} | grep -niE "{{ contour.api_version }}"
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10