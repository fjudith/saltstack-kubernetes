{%- from "kubernetes/map.jinja" import common with context -%}

{# rook-edgefs-common:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/rook-edgefs/common.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/common.yaml #}

rook-edgefs-wait-api:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:8080/apis/edgefs.rook.io/v1'
    - match: Cluster
    - wait_for: 180
    - request_interval: 5
    - status: 200

rook-edgefs-operator:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/rook-edgefs/operator.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/operator.yaml

rook-edgefs-operator-wait:
  cmd.run:
    - require:
      - cmd: rook-edgefs-operator
    - runas: root
    - name: until kubectl -n rook-edgefs-system get pods --selector=app=rook-edgefs-operator --field-selector=status.phase=Running -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'; do printf 'rook-edgefs-operator is not Running' && sleep 5; done
    - use_vt: True
    - timeout: 180

rook-edgefs-cluster:
  cmd.run:
    - require:
      - http: rook-edgefs-wait-api
      - cmd: rook-edgefs-operator-wait
    - watch:
      - file: /srv/kubernetes/manifests/rook-edgefs/cluster.yaml
      - file: /srv/kubernetes/manifests/rook-edgefs/iscsi.yaml
      - file: /srv/kubernetes/manifests/rook-edgefs/isgw.yaml
      - file: /srv/kubernetes/manifests/rook-edgefs/nfs.yaml
      - file: /srv/kubernetes/manifests/rook-edgefs/s3.yaml
      - file: /srv/kubernetes/manifests/rook-edgefs/s3x.yaml
      - file: /srv/kubernetes/manifests/rook-edgefs/swift.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/cluster.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/iscsi.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/isgw.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/nfs.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/s3.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/s3x.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/swift.yaml

rook-edgefs-cluster-wait:
  cmd.run:
    - require:
      - cmd: rook-edgefs-cluster
    - runas: root
    - name: until kubectl -n rook-edgefs get pods --selector=app=rook-edgefs-mgr --field-selector=status.phase=Running -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'; do printf 'rook-edgefs-mgr is not Running' && sleep 5; done
    - use_vt: True
    - timeout: 180

rook-edgefs-iscsi-driver:
  cmd.run:
    - require:
      - http: rook-edgefs-wait-api
      - cmd: rook-edgefs-cluster
    - watch:
      - file: /srv/kubernetes/manifests/rook-edgefs/edgefs-iscsi-csi-driver-config.yaml
      - file: /srv/kubernetes/manifests/rook-edgefs/edgefs-iscsi-csi-driver.yaml
    - name: |
        kubectl create secret generic edgefs-iscsi-csi-driver-config --from-file=/srv/kubernetes/manifests/rook-edgefs/edgefs-iscsi-csi-driver-config.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/edgefs-iscsi-csi-driver.yaml

rook-edgefs-nfs-driver:
  cmd.run:
    - require:
      - http: rook-edgefs-wait-api
      - cmd: rook-edgefs-cluster
    - watch:
      - file: /srv/kubernetes/manifests/rook-edgefs/edgefs-nfs-csi-driver-config.yaml
      - file: /srv/kubernetes/manifests/rook-edgefs/edgefs-nfs-csi-driver.yaml
    - name: |
        kubectl create secret generic edgefs-nfs-csi-driver-config --from-file=/srv/kubernetes/manifests/rook-edgefs/edgefs-nfs-csi-driver-config.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/edgefs-nfs-csi-driver.yaml

rook-edgefs-monitoring:
  cmd.run:
    - require:
      - cmd: rook-edgefs-cluster-wait
    - watch:
      - file: /srv/kubernetes/manifests/rook-edgefs/prometheus.yaml
      - file: /srv/kubernetes/manifests/rook-edgefs/prometheus-service.yaml
      - file: /srv/kubernetes/manifests/rook-edgefs/service-monitor.yaml
    - name: |
        {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/kube-prometheus-prometheus.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/kube-prometheus-service-monitor.yaml
        {%- else %}
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/prometheus.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/prometheus-service.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/service-monitor.yaml
        {%- endif %}