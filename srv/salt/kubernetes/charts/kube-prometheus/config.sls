# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import kube_prometheus with context %}

{% set state = 'absent' %}
{% if kube_prometheus.enabled -%}
  {% set state = 'managed' -%}
{% endif %}

/srv/kubernetes/charts/kube-prometheus:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/kube-prometheus:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

kube-prometheus-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kube-prometheus
    - name: /srv/kubernetes/manifests/kube-prometheus/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/kube-prometheus/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/namespace.yaml
