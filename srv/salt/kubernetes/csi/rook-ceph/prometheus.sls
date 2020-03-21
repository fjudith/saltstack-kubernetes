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
    - use_vt: True
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz/'
    - name: kubectl apply -f /srv/kubernetes/manifests/rook-ceph/prometheus-k8s-rbac.yaml

/srv/kubernetes/manifests/rook-ceph/ceph-exporter.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/templates/ceph-exporter.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/ceph-exporter-service-monitor.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/files/ceph-exporter-service-monitor.yaml
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

rook-ceph-monitoring:
  cmd.run:
    - require:
      - cmd: rook-ceph-cluster
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/ceph-exporter.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/ceph-exporter-service-monitor.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/ceph-exporter.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/ceph-exporter-service-monitor.yaml