rook-ceph-prometheus-rbac:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - name: /srv/kubernetes/manifests/rook-ceph/prometheus-k8s-rbac.yaml
    - source: salt://{{ tpldir }}/files/prometheus-k8s-rbac.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: rook-ceph-cluster
        - file: /srv/kubernetes/manifests/rook-ceph/prometheus-k8s-rbac.yaml
    - runas: root
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: kubectl apply -f /srv/kubernetes/manifests/rook-ceph/prometheus-k8s-rbac.yaml

ceph-exporter:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - name: /srv/kubernetes/manifests/rook-ceph/ceph-exporter.yaml
    - source: salt://{{ tpldir }}/templates/ceph-exporter.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: rook-ceph-cluster
        - file: /srv/kubernetes/manifests/rook-ceph/ceph-exporter.yaml
    - runas: root
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: kubectl apply -f /srv/kubernetes/manifests/rook-ceph/ceph-exporter.yaml

ceph-exporter-service-monitor:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - name: /srv/kubernetes/manifests/rook-ceph/ceph-exporter-service-monitor.yaml
    - source: salt://{{ tpldir }}/files/ceph-exporter-service-monitor.yaml
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: rook-ceph-cluster
        - file: /srv/kubernetes/manifests/rook-ceph/ceph-exporter-service-monitor.yaml
    - runas: root
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: kubectl apply -f /srv/kubernetes/manifests/rook-ceph/ceph-exporter-service-monitor.yaml

csi-service-monitor:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - name: /srv/kubernetes/manifests/rook-ceph/csi-service-monitor.yaml
    - source: salt://{{ tpldir }}/files/csi-service-monitor.yaml
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: rook-ceph-cluster
        - file: /srv/kubernetes/manifests/rook-ceph/csi-service-monitor.yaml
    - runas: root
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: kubectl apply -f /srv/kubernetes/manifests/rook-ceph/csi-service-monitor.yaml