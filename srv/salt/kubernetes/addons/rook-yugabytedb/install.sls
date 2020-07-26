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
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'

query-rook-yugabytedb-api:
  http.wait_for_successful_query:
    - watch:
      - cmd: rook-yugabytedb
    - name: http://127.0.0.1:8080/apis/yugabytedb.rook.io/v1alpha1
    - match: YBCluster
    - wait_for: 120
    - request_interval: 5
    - status: 200

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
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'