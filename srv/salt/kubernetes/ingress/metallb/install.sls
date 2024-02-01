# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import metallb with context %}

{% set state = 'absent' %}
{% set file_state = 'absent' %}
{% if metallb.enabled %}
  {% set state = 'present' %}
  {% set file_state = 'managed' %}
{% endif %}

metallb:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/metallb
    - name: /srv/kubernetes/charts/metallb/values.yaml
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - watch:
      - file: /srv/kubernetes/charts/metallb/values.yaml
    - name: metallb
    {%- if metallb.enabled %}
    - chart: metallb/metallb
    - values: /srv/kubernetes/charts/metallb/values.yaml
    - version: {{ metallb.chart_version }}
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: metallb-system

metallb-wait-api:
  cmd.run:
    - name: |
        http --check-status --verify false \
        --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
        --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
        https://localhost:6443/apis/{{ metallb.api_version }} | grep -niE "{{ metallb.api_version }}"
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10

metallb-ipaddresspool:
  file.{{ file_state }}:
    - require:
      - cmd: metallb-wait-api
      - file: /srv/kubernetes/manifests/metallb
    - name: /srv/kubernetes/manifests/metallb/ipaddresspool.yaml
    - source: salt://{{ tpldir }}/templates/ipaddresspool.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - whatch:
        - file: /srv/kubernetes/manifests/metallb/ipaddresspool.yaml
    - runas: root
    - onlyif: |
        http --check-status --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/metallb.io
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/metallb/ipaddresspool.yaml