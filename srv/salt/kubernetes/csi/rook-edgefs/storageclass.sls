# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import rook_edgefs with context %}

rook-edgefs-local-storage:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - name: /srv/kubernetes/manifests/rook-edgefs/storage-class.yaml
    - source: salt://{{ tpldir }}/files/storage-class.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: rook-edgefs-cluster
    - watch:
      - file: /srv/kubernetes/manifests/rook-edgefs/storage-class.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/storage-class.yaml

rook-edgefs-iscsi:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - name: /srv/kubernetes/manifests/rook-edgefs/iscsi-storageclass.yaml
    - source: salt://{{ tpldir }}/files/iscsi-storageclass.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: rook-edgefs-cluster
      - cmd: rook-edgefs-iscsi-driver
    - watch:
      - file: /srv/kubernetes/manifests/rook-edgefs/iscsi-storageclass.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/iscsi-storageclass.yaml

rook-edgefs-nfs:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - name: /srv/kubernetes/manifests/rook-edgefs/nfs-storageclass.yaml
    - source: salt://{{ tpldir }}/files/nfs-storageclass.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: rook-edgefs-cluster
      - cmd: rook-edgefs-nfs-driver
    - watch:
      - file: /srv/kubernetes/manifests/rook-edgefs/nfs-storageclass.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/nfs-storageclass.yaml

{% if rook_edgefs.get('default_storageclass', {'enabled': False}).enabled %}
rook-edgefs-default-storageclass:
  cmd.run:
    - require:
      - cmd: rook-edgefs-block
      - cmd: rook-edgefsfs
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
    - name: |
        kubectl patch storageclass {{ rook_edgefs.default_storageclass.name }} -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' 
{% endif %}