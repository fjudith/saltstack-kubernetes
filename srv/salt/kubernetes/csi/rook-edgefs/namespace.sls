# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import rook_edgefs with context %}

rook-edgefs-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - name: /srv/kubernetes/manifests/rook-edgefs/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/rook-edgefs/namespace.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/namespace.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'