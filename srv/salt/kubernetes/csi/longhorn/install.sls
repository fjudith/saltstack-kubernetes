# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import longhorn with context %}
{%- from "kubernetes/map.jinja" import common with context -%}

longhorn:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/longhorn/longhorn.yaml
    - runas: root
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/longhorn/longhorn.yaml

longhorn-manager-wait:
  cmd.run:
    - require:
      - cmd: longhorn
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n longhorn-system get daemonset longhorn-manager; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n longhorn-system get daemonset longhorn-manager -o jsonpath='{.status.desiredNumberScheduled}') && \
        
        echo "Waiting for longhorn-manager to be up and running" && \
        
        while [ "$(kubectl -n longhorn-system get daemonset longhorn-manager -o jsonpath='{.status.numberReady}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n longhorn-system get daemonset longhorn-manager

longhorn-csi-plugin-wait:
  cmd.run:
    - require:
      - cmd: longhorn
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n longhorn-system get daemonset longhorn-csi-plugin; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n longhorn-system get daemonset longhorn-csi-plugin -o jsonpath='{.status.desiredNumberScheduled}') && \
        
        echo "Waiting for longhorn-csi-plugin to be up and running" && \
        
        while [ "$(kubectl -n longhorn-system get daemonset longhorn-csi-plugin -o jsonpath='{.status.numberReady}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n longhorn-system get daemonset longhorn-csi-plugin

longhorn-csi-attacher-wait:
  cmd.run:
    - require:
      - cmd: longhorn
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n longhorn-system get deployment csi-attacher; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n longhorn-system get deployment csi-attacher -o jsonpath='{.status.replicas}') && \
        
        echo "Waiting for csi-attacher to be up and running" && \
        
        while [ "$(kubectl -n longhorn-system get deployment csi-attacher -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n longhorn-system get deployment csi-attacher

longhorn-csi-provisioner-wait:
  cmd.run:
    - require:
      - cmd: longhorn
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n longhorn-system get deployment csi-provisioner; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n longhorn-system get deployment csi-provisioner -o jsonpath='{.status.replicas}') && \
        
        echo "Waiting for csi-provisioner to be up and running" && \
        
        while [ "$(kubectl -n longhorn-system get deployment csi-provisioner -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n longhorn-system get deployment csi-provisioner

longhorn-csi-resizer-wait:
  cmd.run:
    - require:
      - cmd: longhorn
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n longhorn-system get deployment csi-resizer; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n longhorn-system get deployment csi-resizer -o jsonpath='{.status.replicas}') && \
        
        echo "Waiting for csi-resizer to be up and running" && \
        
        while [ "$(kubectl -n longhorn-system get deployment csi-resizer -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n longhorn-system get deployment csi-resizer
