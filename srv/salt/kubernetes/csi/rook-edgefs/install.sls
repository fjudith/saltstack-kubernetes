# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import rook_edgefs with context %}
{%- from "kubernetes/map.jinja" import common with context -%}

{# rook-edgefs-common:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/rook-edgefs/common.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/common.yaml #}

rook-edgefs-operator:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/rook-edgefs/operator.yaml
    - runas: root
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/operator.yaml

rook-edgefs-operator-wait:
  cmd.run:
    - require:
      - cmd: rook-edgefs-operator
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n rook-edgefs-system get deployment rook-edgefs-operator; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n rook-edgefs-system get deployment rook-edgefs-operator -o jsonpath='{.status.replicas}') && \
        
        echo "Waiting for rook-edgefs-operator to be up and running" && \
        
        while [ "$(kubectl -n rook-edgefs-system get deployment rook-edgefs-operator -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n rook-edgefs-system get deployment rook-edgefs-operator        
        

rook-edgefs-discover-wait:
  cmd.run:
    - require:
      - cmd: rook-edgefs-operator
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n rook-edgefs-system get daemonset rook-discover; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n rook-edgefs-system get daemonset rook-discover -o jsonpath='{.status.desiredNumberScheduled}') && \
        
        echo "Waiting for rook-discover to be up and running" && \
        
        while [ "$(kubectl -n rook-edgefs-system get daemonset rook-discover -o jsonpath='{.status.numberReady}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n rook-edgefs-system get daemonset rook-discover

rook-edgefs-wait-api:
  http.wait_for_successful_query:
    - require:
      - cmd: rook-edgefs-operator-wait
      - cmd: rook-edgefs-discover-wait
    - name: 'http://127.0.0.1:8080/apis/edgefs.rook.io/v1'
    - match: Cluster
    - wait_for: 180
    - request_interval: 5
    - status: 200


rook-edgefs-cluster:
  cmd.run:
    - require:
      - http: rook-edgefs-wait-api
    - watch:
      - file: /srv/kubernetes/manifests/rook-edgefs/cluster.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/cluster.yaml

rook-edgefs-mgr-wait:
  cmd.run:
    - require:
      - cmd: rook-edgefs-cluster
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n rook-edgefs get deployment rook-edgefs-mgr; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n rook-edgefs get deployment rook-edgefs-mgr -o jsonpath='{.status.replicas}') && \
        
        echo "Waiting for rook-edgefs-mgr to be up and running" && \
        
        while [ "$(kubectl -n rook-edgefs get deployment rook-edgefs-mgr -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n rook-edgefs get deployment rook-edgefs-mgr

rook-edgefs-target-wait:
  cmd.run:
    - require:
      - cmd: rook-edgefs-mgr-wait
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n rook-edgefs get statefulset rook-edgefs-target; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n rook-edgefs get statefulset rook-edgefs-target -o jsonpath='{.status.replicas}') && \
        
        echo "Waiting for rook-edgefs-target to be up and running" && \
        
        while [ "$(kubectl -n rook-edgefs get statefulset rook-edgefs-target -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \
        
        kubectl -n rook-edgefs get statefulset rook-edgefs-target

rook-edgefs-system-init:
  cmd.run:
    - require:
      - cmd: rook-edgefs-target-wait
    - runas: root
    - timeout: 180
    - success_retcodes: [0, 1]
    - name: | 
        kubectl exec -it -n rook-edgefs $(kubectl -n rook-edgefs -l app=rook-edgefs-mgr get po -o jsonpath='{range .items[*]}{.metadata.name}') -- toolbox \
          efscli system init -f
        
        kubectl exec -it -n rook-edgefs $(kubectl -n rook-edgefs -l app=rook-edgefs-mgr get po -o jsonpath='{range .items[*]}{.metadata.name}') -- toolbox \
          efscli cluster create {{ rook_edgefs.cluster }}
        
        kubectl exec -it -n rook-edgefs $(kubectl -n rook-edgefs -l app=rook-edgefs-mgr get po -o jsonpath='{range .items[*]}{.metadata.name}') -- toolbox \
          efscli tenant create {{ rook_edgefs.cluster }}/{{ rook_edgefs.tenant }}

        kubectl exec -it -n rook-edgefs $(kubectl -n rook-edgefs -l app=rook-edgefs-mgr get po -o jsonpath='{range .items[*]}{.metadata.name}') -- toolbox \
           efscli user create {{ rook_edgefs.cluster }}/{{ rook_edgefs.tenant }} {{ rook_edgefs.username }} {{ rook_edgefs.password }} admin

rook-edgefs-monitoring:
  cmd.run:
    - require:
      - cmd: rook-edgefs-mgr-wait
    - watch:
      - file: /srv/kubernetes/manifests/rook-edgefs/prometheus.yaml
      - file: /srv/kubernetes/manifests/rook-edgefs/prometheus-service.yaml
      - file: /srv/kubernetes/manifests/rook-edgefs/service-monitor.yaml
    - runas: root
    - name: |
        {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/kube-prometheus-prometheus.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/kube-prometheus-service-monitor.yaml
        {%- else %}
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/prometheus.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/prometheus-service.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/service-monitor.yaml
        {%- endif %}