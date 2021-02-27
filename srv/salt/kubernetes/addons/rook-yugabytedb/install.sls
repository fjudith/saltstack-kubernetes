# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import rook_yugabytedb with context %}

rook-yugabytedb:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/rook-yugabytedb/operator.yaml
        - cmd: rook-yugabytedb-namespace
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-yugabytedb/operator.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose

query-rook-yugabytedb-api:
    - watch:
      - cmd: rook-yugabytedb
  cmd.run:
    - name: |
        http --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/yugabytedb.rook.io/v1alpha1
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10

rook-yugabytedb-cluster:
  cmd.run:
    - require:
        - http: query-rook-yugabytedb-api
        - cmd: rook-yugabytedb-namespace
    - watch:
        - file: /srv/kubernetes/manifests/rook-yugabytedb/cluster.yaml
    - runas: root    
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-yugabytedb/cluster.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose