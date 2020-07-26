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
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'

query-rook-cockroachdb-api:
  http.wait_for_successful_query:
    - watch:
      - cmd: rook-cockroachdb
    - name: http://127.0.0.1:8080/apis/cockroachdb.rook.io/v1alpha1
    - match: Cluster
    - wait_for: 120
    - request_interval: 5
    - status: 200

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
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'