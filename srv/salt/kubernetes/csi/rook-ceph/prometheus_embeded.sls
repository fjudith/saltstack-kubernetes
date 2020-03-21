/srv/kubernetes/manifests/rook-ceph/prometheus-ceph-rules.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/files/prometheus-ceph-rules.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/prometheus.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/files/prometheus.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/prometheus-service.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/files/prometheus-service.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/service-monitor.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/files/service-monitor.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

rook-ceph-monitoring:
  cmd.run:
    - require:
      - cmd: rook-ceph-ingress
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/prometheus-ceph-rules.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/prometheus.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/prometheus-service.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/service-monitor.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/prometheus.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/prometheus-service.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/service-monitor.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/prometheus-ceph-rules.yaml
        {%- endif %}