# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import rook_ceph with context %}

minio-operator-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - name: /srv/kubernetes/manifests/rook-ceph/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/rook-ceph/namespace.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/namespace.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'