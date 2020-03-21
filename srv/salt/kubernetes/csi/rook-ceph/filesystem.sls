# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import rook_ceph with context %}

rook-ceph-mds:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - name: /srv/kubernetes/manifests/rook-ceph/filesystem.yaml
    - source: salt://{{ tpldir }}/files/filesystem.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: rook-ceph-cluster
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/filesystem.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/filesystem.yaml

rook-ceph-mds-myfs-wait:
  cmd.run:
    - require:
      - cmd: rook-ceph-mds
    - runas: root
    - use_vt: True
    - timeout: {{ rook_ceph.timeout }}
    - name: |
        until kubectl -n rook-ceph get deployment rook-ceph-mds-myfs-a; do printf '.' && sleep 5 ; done
        echo "" && \
        REPLICAS=$(kubectl -n rook-ceph get deployment rook-ceph-mds-myfs-a -o jsonpath='{.status.replicas}') && \
        echo "Waiting for rook-ceph-mds-myfs-a to be up and running" && \
        while [ "$(kubectl -n rook-ceph get deployment rook-ceph-mds-myfs-a -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \
        kubectl -n rook-ceph get deployment rook-ceph-mds-myfs-a