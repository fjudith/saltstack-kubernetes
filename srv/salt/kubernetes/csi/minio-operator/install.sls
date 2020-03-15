# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import minio_operator with context %}

minio-client:
  file.managed:
    - name: /usr/local/bin/mc
    - source: https://dl.min.io/client/mc/release/linux-amd64/archive/mc.{{ minio_operator.client_version }}
    - source_hash: {{ minio_operator.source_hash }}
    - mode: "0555"
    - user: root
    - group: root

minio-operator:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/minio-operator/minio-operator.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/minio-operator/minio-operator.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'

query-minio-operator-api:
  http.wait_for_successful_query:
    - watch:
      - cmd: minio-operator
    - name: http://127.0.0.1:8080/apis/miniocontroller.min.io/v1beta1
    - wait_for: 120
    - request_interval: 5
    - status: 200

minio-cluster:
  cmd.run:
    - require:
        - http: query-minio-operator-api
    - watch:
        - file: /srv/kubernetes/manifests/minio-operator/minioinstance.yaml
    - runas: root    
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/minio-operator/minioinstance.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'