# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import openebs with context %}
{%- from "kubernetes/map.jinja" import common with context -%}

openebs:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/openebs/openebs-operator.yaml
    - runas: root
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/openebs/openebs-operator.yaml

openebs-maya-apiserver-wait:
  cmd.run:
    - require:
      - cmd: openebs
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n openebs get deployment maya-apiserver; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n openebs get deployment maya-apiserver -o jsonpath='{.status.replicas}') && \
        
        echo "Waiting for maya-apiserver to be up and running" && \
        
        while [ "$(kubectl -n openebs get deployment maya-apiserver -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n openebs get deployment maya-apiserver

openebs-provisioner-wait:
  cmd.run:
    - require:
      - cmd: openebs
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n openebs get deployment openebs-provisioner; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n openebs get deployment openebs-provisioner -o jsonpath='{.status.replicas}') && \
        
        echo "Waiting for openebs-provisioner to be up and running" && \
        
        while [ "$(kubectl -n openebs get deployment openebs-provisioner -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n openebs get deployment openebs-provisioner

openebs-snapshot-operator-wait:
  cmd.run:
    - require:
      - cmd: openebs
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n openebs get deployment openebs-snapshot-operator; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n openebs get deployment openebs-snapshot-operator -o jsonpath='{.status.replicas}') && \
        
        echo "Waiting for openebs-snapshot-operator to be up and running" && \
        
        while [ "$(kubectl -n openebs get deployment openebs-snapshot-operator -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n openebs get deployment openebs-snapshot-operator

openebs-ndm-wait:
  cmd.run:
    - require:
      - cmd: openebs
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n openebs get daemonset openebs-ndm; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n openebs get daemonset openebs-ndm -o jsonpath='{.status.desiredNumberScheduled}') && \
        
        echo "Waiting for openebs-ndm to be up and running" && \
        
        while [ "$(kubectl -n openebs get daemonset openebs-ndm -o jsonpath='{.status.numberReady}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n openebs get daemonset openebs-ndm

openebs-ndm-operator-wait:
  cmd.run:
    - require:
      - cmd: openebs
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n openebs get deployment openebs-ndm-operator; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n openebs get deployment openebs-ndm-operator -o jsonpath='{.status.replicas}') && \
        
        echo "Waiting for openebs-ndm-operator to be up and running" && \
        
        while [ "$(kubectl -n openebs get deployment openebs-ndm-operator -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n openebs get deployment openebs-ndm-operator

openebs-admission-server-wait:
  cmd.run:
    - require:
      - cmd: openebs
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n openebs get deployment openebs-admission-server; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n openebs get deployment openebs-admission-server -o jsonpath='{.status.replicas}') && \
        
        echo "Waiting for openebs-admission-server to be up and running" && \
        
        while [ "$(kubectl -n openebs get deployment openebs-admission-server -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n openebs get deployment openebs-admission-server

openebs-localpv-provisioner-wait:
  cmd.run:
    - require:
      - cmd: openebs
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n openebs get deployment openebs-localpv-provisioner; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n openebs get deployment openebs-localpv-provisioner -o jsonpath='{.status.replicas}') && \
        
        echo "Waiting for openebs-localpv-provisioner to be up and running" && \
        
        while [ "$(kubectl -n openebs get deployment openebs-localpv-provisioner -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n openebs get deployment openebs-localpv-provisioner

{# openebs-manager-wait:
  cmd.run:
    - require:
      - cmd: openebs
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n openebs get daemonset openebs-manager; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n openebs get daemonset openebs-manager -o jsonpath='{.status.desiredNumberScheduled}') && \
        
        echo "Waiting for openebs-manager to be up and running" && \
        
        while [ "$(kubectl -n openebs get daemonset openebs-manager -o jsonpath='{.status.numberReady}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n openebs get daemonset openebs-manager

openebs-csi-plugin-wait:
  cmd.run:
    - require:
      - cmd: openebs
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n openebs get daemonset openebs-csi-plugin; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n openebs get daemonset openebs-csi-plugin -o jsonpath='{.status.desiredNumberScheduled}') && \
        
        echo "Waiting for openebs-csi-plugin to be up and running" && \
        
        while [ "$(kubectl -n openebs get daemonset openebs-csi-plugin -o jsonpath='{.status.numberReady}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n openebs get daemonset openebs-csi-plugin

openebs-csi-attacher-wait:
  cmd.run:
    - require:
      - cmd: openebs
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n openebs get deployment csi-attacher; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n openebs get deployment csi-attacher -o jsonpath='{.status.replicas}') && \
        
        echo "Waiting for csi-attacher to be up and running" && \
        
        while [ "$(kubectl -n openebs get deployment csi-attacher -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n openebs get deployment csi-attacher

openebs-csi-provisioner-wait:
  cmd.run:
    - require:
      - cmd: openebs
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n openebs get deployment csi-provisioner; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n openebs get deployment csi-provisioner -o jsonpath='{.status.replicas}') && \
        
        echo "Waiting for csi-provisioner to be up and running" && \
        
        while [ "$(kubectl -n openebs get deployment csi-provisioner -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n openebs get deployment csi-provisioner

openebs-csi-resizer-wait:
  cmd.run:
    - require:
      - cmd: openebs
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n openebs get deployment csi-resizer; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n openebs get deployment csi-resizer -o jsonpath='{.status.replicas}') && \
        
        echo "Waiting for csi-resizer to be up and running" && \
        
        while [ "$(kubectl -n openebs get deployment csi-resizer -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n openebs get deployment csi-resizer #}
