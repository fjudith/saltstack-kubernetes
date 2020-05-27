minio-operator-prometheus-rbac:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/minio-operator
    - name: /srv/kubernetes/manifests/minio-operator/prometheus-k8s-rbac.yaml
    - source: salt://{{ tpldir }}/files/prometheus-k8s-rbac.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: minio-cluster
        - file: /srv/kubernetes/manifests/minio-operator/prometheus-k8s-rbac.yaml
    - runas: root
    - use_vt: True
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz/'
    - name: kubectl apply -f /srv/kubernetes/manifests/minio-operator/prometheus-k8s-rbac.yaml

minio-operator-service-monitor:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/minio-operator
    - name: /srv/kubernetes/manifests/minio-operator/service-monitor.yaml
    - source: salt://{{ tpldir }}/files/service-monitor.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: minio-cluster
        - file: /srv/kubernetes/manifests/minio-operator/service-monitor.yaml
    - runas: root
    - use_vt: True
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz/'
    - name: kubectl apply -f /srv/kubernetes/manifests/minio-operator/service-monitor.yaml