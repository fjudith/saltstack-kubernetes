# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import kubeless with context %}

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