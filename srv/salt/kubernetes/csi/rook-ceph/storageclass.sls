# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import rook_ceph with context %}

rook-ceph-block:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - name: /srv/kubernetes/manifests/rook-ceph/storageclass.yaml
    - source: salt://{{ tpldir }}/files/storageclass.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: rook-ceph-cluster
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/storageclass.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/storageclass.yaml

rook-cephfs:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - name: /srv/kubernetes/manifests/rook-ceph/filesystem-storageclass.yaml
    - source: salt://{{ tpldir }}/files/filesystem-storageclass.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: rook-ceph-cluster
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/filesystem-storageclass.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/filesystem-storageclass.yaml

{% if rook_ceph.get('default_storageclass', {'enabled': False}).enabled %}
rook-ceph-default-storageclass:
  cmd.run:
    - require:
      - cmd: rook-ceph-block
      - cmd: rook-cephfs
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: |
        kubectl patch storageclass {{ rook_ceph.default_storageclass.name }} -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' 
{% endif %}