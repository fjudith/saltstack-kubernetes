# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import rook_ceph with context %}

rook-ceph-tools:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - name: /srv/kubernetes/manifests/rook-ceph/toolbox.yaml
    - source: salt://{{ tpldir }}/templates/toolbox.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: rook-ceph-cluster
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/toolbox.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/toolbox.yaml

rook-ceph-tools-wait:
  cmd.run:
    - require:
      - cmd: rook-ceph-tools
    - runas: root
    - timeout: {{ rook_ceph.timeout }}
    - name: |
        until kubectl -n rook-ceph get deployment rook-ceph-tools; do printf '.' && sleep 5 ; done
        echo "" && \
        REPLICAS=$(kubectl -n rook-ceph get deployment rook-ceph-tools -o jsonpath='{.status.replicas}') && \
        echo "Waiting for rook-ceph-tools to be up and running" && \
        while [ "$(kubectl -n rook-ceph get deployment rook-ceph-tools -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \
        kubectl -n rook-ceph get deployment rook-ceph-tools