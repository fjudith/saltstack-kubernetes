# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import nats_operator with context %}

{% set state = 'absent' %}
{% set file_state = 'absent' %}
{% if nats_operator.enabled %}
  {% set state = 'present' %}
  {% set file_state = 'managed' %}
{% endif %}

nats-operator:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/nats-operator
    - name: /srv/kubernetes/charts/nats-operator/values.yaml
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - watch:
      - file: /srv/kubernetes/charts/nats-operator/values.yaml
    - name: nats-operator
    {%- if nats_operator.enabled %}
    - chart: nats/nats-operator
    - values: /srv/kubernetes/charts/nats-operator/values.yaml
    - version: {{ nats_operator.chart_version }}
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: nats-operator

nats-operator-wait-api:
  cmd.run:
    - name: |
        http --check-status --verify false \
        --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
        --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
        https://localhost:6443/apis/{{ nats_operator.api_version }} | grep -niE "{{ nats_operator.api_version }}"
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10

nats-operator-nats-cluster:
  file.{{ file_state }}:
    - require:
      - file: /srv/kubernetes/manifests/nats-operator
    - name: /srv/kubernetes/manifests/nats-operator/nats-cluster.yaml
    - source: salt://{{ tpldir }}/templates/nats-cluster.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: nats-operator-wait-api
    - whatch:
        - file: /srv/kubernetes/manifests/nats-operator/nats-cluster.yaml
    - runas: root
    - onlyif: |
        http --check-status --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/{{ nats_operator.api_version }}
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/nats-cluster.yaml

nats-operator-stan-cluster:
  file.{{ file_state }}:
    - require:
      - cmd: nats-operator-wait-api
      - file: /srv/kubernetes/manifests/nats-operator
    - name: /srv/kubernetes/manifests/nats-operator/stan-cluster.yaml
    - source: salt://{{ tpldir }}/templates/stan-cluster.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: nats-operator-wait-api
    - whatch:
        - file: /srv/kubernetes/manifests/nats-operator/stan-cluster.yaml
    - runas: root
    - onlyif: |
        http --check-status --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/{{ nats_operator.api_version }}
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/stan-cluster.yaml