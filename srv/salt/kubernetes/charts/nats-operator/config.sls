# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import nats_operator with context %}

{% set state = 'absent' %}
{% if nats_operator.enabled -%}
  {% set state = 'managed' -%}
{% endif %}

/srv/kubernetes/charts/nats-operator:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/nats-operator:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

nats-operator-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nats-operator
    - name: /srv/kubernetes/manifests/nats-operator/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/nats-operator/namespace.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/namespace.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose