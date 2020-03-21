rook-ceph-pool:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - name: /srv/kubernetes/manifests/rook-ceph/pool.yaml
    - source: salt://{{ tpldir }}/files/pool.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: rook-ceph-cluster
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/pool.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/pool.yaml