# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import rook_ceph with context %}

rook-ceph-crds:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/crds.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/crds.yaml

rook-ceph-common:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/common.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/common.yaml

rook-ceph-wait-api:
  cmd.run:
    - name: |
        http --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/ceph.rook.io/v1
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: {{ rook_ceph.timeout }}

rook-ceph-operator:
  cmd.run:
    - require:
      - http: rook-ceph-wait-api
      - cmd: rook-ceph-common
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/operator.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/operator.yaml

rook-ceph-operator-wait:
  cmd.run:
    - require:
      - cmd: rook-ceph-operator
    - runas: root
    - timeout: {{ rook_ceph.timeout }}
    - name: |
        until kubectl -n rook-ceph get deployment rook-ceph-operator; do printf '.' && sleep 5 ; done
        echo "" && \
        REPLICAS=$(kubectl -n rook-ceph get deployment rook-ceph-operator -o jsonpath='{.status.replicas}') && \
        echo "Waiting for rook-ceph-operator to be up and running" && \
        while [ "$(kubectl -n rook-ceph get deployment rook-ceph-operator -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \
        kubectl -n rook-ceph get deployment rook-ceph-operator

rook-ceph-discover-wait:
  cmd.run:
    - require:
      - cmd: rook-ceph-operator
    - runas: root
    - timeout: {{ rook_ceph.timeout }}
    - name: |
        until kubectl -n rook-ceph get daemonset rook-discover; do printf '.' && sleep 5 ; done
        echo "" && \
        REPLICAS=$(kubectl -n rook-ceph get daemonset rook-discover -o jsonpath='{.status.desiredNumberScheduled}') && \
        echo "Waiting for rook-discover to be up and running" && \
        while [ "$(kubectl -n rook-ceph get daemonset rook-discover -o jsonpath='{.status.numberReady}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \
        kubectl -n rook-ceph get daemonset rook-discover

rook-ceph-cluster:
  cmd.run:
    - require:
      - http: rook-ceph-wait-api
      - cmd: rook-ceph-operator-wait
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/cluster.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/cluster.yaml

rook-ceph-mgr-a-wait:
  cmd.run:
    - require:
      - cmd: rook-ceph-cluster
    - runas: root
    - timeout: {{ rook_ceph.timeout }}
    - name: |
        until kubectl -n rook-ceph get deployment rook-ceph-mgr-a; do printf '.' && sleep 5 ; done
        echo "" && \
        REPLICAS=$(kubectl -n rook-ceph get deployment rook-ceph-mgr-a -o jsonpath='{.status.replicas}') && \
        echo "Waiting for rook-ceph-mgr-a to be up and running" && \
        while [ "$(kubectl -n rook-ceph get deployment rook-ceph-mgr-a -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \
        kubectl -n rook-ceph get deployment rook-ceph-mgr-a

rook-ceph-mon-a-wait:
  cmd.run:
    - require:
      - cmd: rook-ceph-cluster
    - runas: root
    - timeout: {{ rook_ceph.timeout }}
    - name: |
        until kubectl -n rook-ceph get deployment rook-ceph-mon-a; do printf '.' && sleep 5 ; done
        echo "" && \
        REPLICAS=$(kubectl -n rook-ceph get deployment rook-ceph-mon-a -o jsonpath='{.status.replicas}') && \
        echo "Waiting for rook-ceph-mon-a to be up and running" && \
        while [ "$(kubectl -n rook-ceph get deployment rook-ceph-mon-a -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \
        kubectl -n rook-ceph get deployment rook-ceph-mon-a

rook-ceph-osd-0-wait:
  cmd.run:
    - require:
      - cmd: rook-ceph-mon-a-wait
    - runas: root
    - timeout: {{ rook_ceph.timeout }}
    - name: |
        until kubectl -n rook-ceph get deployment rook-ceph-osd-0; do printf '.' && sleep 5 ; done
        echo "" && \
        REPLICAS=$(kubectl -n rook-ceph get deployment rook-ceph-osd-0 -o jsonpath='{.status.replicas}') && \
        echo "Waiting for rook-ceph-osd-0 to be up and running" && \
        while [ "$(kubectl -n rook-ceph get deployment rook-ceph-osd-0 -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \
        kubectl -n rook-ceph get deployment rook-ceph-osd-0

rook-ceph-client:
  cmd.run:
    - require:
      - http: rook-ceph-wait-api
      - cmd: rook-ceph-operator-wait
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/client.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/client.yaml