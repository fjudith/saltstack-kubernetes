# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import portworx with context %}

portworx:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/portworx
    - name: /srv/kubernetes/manifests/portworx/portworx.yaml
    - source: {{ portworx.manifest_url }}
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/portworx/portworx.yaml
      - cmd: portworx-namespace
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/portworx/portworx.yaml

portworx-api-wait:
  cmd.run:
    - require:
      - cmd: portworx
    - runas: root
    - timeout: 600
    - name: |
        until kubectl -n kube-system get daemonset portworx-api; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n kube-system get daemonset portworx-api -o jsonpath='{.status.desiredNumberScheduled}') && \
        
        echo "Waiting for portworx-api to be up and running" && \
        
        while [ "$(kubectl -n kube-system get daemonset portworx-api -o jsonpath='{.status.numberReady}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n kube-system get daemonset portworx-api

portworx-wait:
  cmd.run:
    - require:
      - cmd: portworx
    - runas: root
    - timeout: 600
    - name: |
        until kubectl -n kube-system get daemonset portworx; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n kube-system get daemonset portworx -o jsonpath='{.status.desiredNumberScheduled}') && \
        
        echo "Waiting for portworx to be up and running" && \
        
        while [ "$(kubectl -n kube-system get daemonset portworx -o jsonpath='{.status.numberReady}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n kube-system get daemonset portworx