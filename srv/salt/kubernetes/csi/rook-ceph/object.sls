# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import rook_ceph with context %}

rook-ceph-rgw:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - name: /srv/kubernetes/manifests/rook-ceph/object.yaml
    - source: salt://{{ tpldir }}/templates/object.yaml
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: rook-ceph-cluster
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/object.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/object.yaml

rook-ceph-rgw-my-store-wait:
  cmd.run:
    - require:
      - cmd: rook-ceph-rgw
    - runas: root
    - timeout: {{ rook_ceph.timeout }}
    - name: |
        until kubectl -n rook-ceph get deployment rook-ceph-rgw-my-store-a; do printf '.' && sleep 5 ; done
        echo "" && \
        REPLICAS=$(kubectl -n rook-ceph get deployment rook-ceph-rgw-my-store-a -o jsonpath='{.status.replicas}') && \
        echo "Waiting for rook-ceph-rgw-my-store-a to be up and running" && \
        while [ "$(kubectl -n rook-ceph get deployment rook-ceph-rgw-my-store-a -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \
        kubectl -n rook-ceph get deployment rook-ceph-rgw-my-store-a