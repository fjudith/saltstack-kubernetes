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
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/minio-operator/minio-operator.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose

query-minio-operator-api:
  cmd.run:
    - watch:
      - cmd: minio-operator
    - name: |
        http --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/operator.min.io/v1
    - use_vt: True
    - retry:
        attempts: 10
        interval: 5

minio-cluster:
  cmd.run:
    - require:
        - cmd: query-minio-operator-api
    - watch:
        - file: /srv/kubernetes/manifests/minio-operator/minioinstance.yaml
    - runas: root    
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/minio-operator/minioinstance.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose