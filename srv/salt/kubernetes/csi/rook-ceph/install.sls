{%- from "kubernetes/map.jinja" import common with context -%}

rook-ceph-common:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/common.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/common.yaml

rook-ceph-operator:
  cmd.run:
    - require:
      - cmd: rook-ceph-common
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/operator.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/operator.yaml

rook-ceph-operator-wait:
  cmd.run:
    - require:
      - cmd: rook-ceph-operator
    - runas: root
    - name: until kubectl -n rook-ceph get pods --selector=app=rook-ceph-operator --field-selector=status.phase=Running -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'; do printf 'rook-ceph-operator is not Running' && sleep 5; done
    - use_vt: True
    - timeout: 180

rook-ceph-cluster:
  cmd.run:
    - require:
      - cmd: rook-ceph-operator-wait
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/cluster.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/pool.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/object.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/filesystem.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/cluster.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/pool.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/object.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/filesystem.yaml

rook-ceph-cluster-wait:
  cmd.run:
    - require:
      - cmd: rook-ceph-cluster
    - runas: root
    - name: until kubectl -n rook-ceph get pods --selector=app=rook-ceph-mgr --field-selector=status.phase=Running -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'; do printf 'rook-ceph-mgr is not Running' && sleep 5; done
    - use_vt: True
    - timeout: 180

rook-ceph-mon-wait:
  cmd.run:
    - require:
      - cmd: rook-ceph-cluster
    - runas: root
    - name: until kubectl -n rook-ceph get pods --selector=app=rook-ceph-mon --field-selector=status.phase=Running -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'; do printf 'rook-ceph-mon are not Running' && sleep 5; done
    - use_vt: True
    - timeout: 180

rook-ceph-osd-wait:
  cmd.run:
    - require:
      - cmd: rook-ceph-cluster
    - runas: root
    - name: until kubectl -n rook-ceph get pods --selector=app=rook-ceph-osd --field-selector=status.phase=Running -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'; do printf 'rook-ceph-osd are not Running' && sleep 5; done
    - use_vt: True
    - timeout: 180

rook-ceph-rgw-wait:
  cmd.run:
    - require:
      - cmd: rook-ceph-cluster
    - runas: root
    - name: until kubectl -n rook-ceph get pods --selector=app=rook-ceph-rgw --field-selector=status.phase=Running -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'; do printf 'rook-ceph-rgw are not Running' && sleep 5; done
    - use_vt: True
    - timeout: 180

rook-ceph-monitoring:
  cmd.run:
    - require:
      - cmd: rook-ceph-cluster-wait
      - cmd: rook-ceph-mon-wait
      - cmd: rook-ceph-osd-wait
      - cmd: rook-ceph-rgw-wait
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/toolbox.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/prometheus-ceph-rules.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/prometheus.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/prometheus-service.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/service-monitor.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/ceph-exporter.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/kube-prometheus-prometheus.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/kube-prometheus-service-monitor.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/kube-prometheus-grafana-dashboard.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/toolbox.yaml
        {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/ceph-exporter.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/kube-prometheus-grafana-dashboard.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/kube-prometheus-prometheus.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/kube-prometheus-service-monitor.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/prometheus-ceph-rules.yaml
        {%- else %}
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/prometheus.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/prometheus-service.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/service-monitor.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/prometheus-ceph-rules.yaml
        {%- endif %}

rook-ceph-nfs-install:
  cmd.run:
    - require:
      - cmd: rook-ceph-monitoring
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/common.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/nfs.yaml