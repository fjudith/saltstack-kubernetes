# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import rook_cockroachdb with context %}

rook-cockroachdb:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/rook-cockroachdb/operator.yaml
        - cmd: rook-cockroachdb-namespace
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-cockroachdb/operator.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose

query-rook-cockroachdb-api:
    - watch:
      - cmd: rook-cockroachdb
  cmd.run:
    - name: |
        http --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/cockroachdb.rook.io/v1alpha1
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10

rook-cockroachdb-cluster:
  cmd.run:
    - require:
        - http: query-rook-cockroachdb-api
        - cmd: rook-cockroachdb-namespace
    - watch:
        - file: /srv/kubernetes/manifests/rook-cockroachdb/cluster.yaml
    - runas: root    
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-cockroachdb/cluster.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose