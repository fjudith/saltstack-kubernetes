{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}

/srv/kubernetes/manifests/rook-ceph:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/rook-ceph/rbac.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://kubernetes/csi/rook-ceph/files/rbac.yaml
    - user: root
    - group: root
    - file_mode: 644

/srv/kubernetes/manifests/rook-ceph/cluster.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://kubernetes/csi/rook-ceph/files/cluster.yaml
    - user: root
    - group: root
    - file_mode: 644

/srv/kubernetes/manifests/rook-ceph/dashboard-external.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://kubernetes/csi/rook-ceph/files/dashboard-external.yaml
    - user: root
    - group: root
    - file_mode: 644

/srv/kubernetes/manifests/rook-ceph/filesystem.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://kubernetes/csi/rook-ceph/files/filesystem.yaml
    - user: root
    - group: root
    - file_mode: 644

/srv/kubernetes/manifests/rook-ceph/object.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://kubernetes/csi/rook-ceph/files/object.yaml
    - user: root
    - group: root
    - file_mode: 644

/srv/kubernetes/manifests/rook-ceph/operator.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://kubernetes/csi/rook-ceph/templates/operator.yaml.jinja
    - user: root
    - group: root
    - file_mode: 644
    - template: jinja

/srv/kubernetes/manifests/rook-ceph/pool.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://kubernetes/csi/rook-ceph/files/pool.yaml
    - user: root
    - group: root
    - file_mode: 644

/srv/kubernetes/manifests/rook-ceph/storageclass.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://kubernetes/csi/rook-ceph/files/storageclass.yaml
    - user: root
    - group: root
    - file_mode: 644

/srv/kubernetes/manifests/rook-ceph/toolbox.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://kubernetes/csi/rook-ceph/files/toolbox.yaml
    - user: root
    - group: root
    - file_mode: 644

/srv/kubernetes/manifests/rook-ceph/prometheus-service.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://kubernetes/csi/rook-ceph/files/prometheus-service.yaml
    - user: root
    - group: root
    - file_mode: 644

/srv/kubernetes/manifests/rook-ceph/prometheus.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://kubernetes/csi/rook-ceph/files/prometheus.yaml
    - user: root
    - group: root
    - file_mode: 644

/srv/kubernetes/manifests/rook-ceph/service-monitor.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://kubernetes/csi/rook-ceph/files/service-monitor.yaml
    - user: root
    - group: root
    - file_mode: 644

/srv/kubernetes/manifests/rook-ceph/kube-prometheus-prometheus.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://kubernetes/csi/rook-ceph/files/kube-prometheus-prometheus.yaml
    - user: root
    - group: root
    - file_mode: 644

/srv/kubernetes/manifests/rook-ceph/kube-prometheus-ceph-exporter.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://kubernetes/csi/rook-ceph/files/kube-prometheus-ceph-exporter.yaml
    - user: root
    - group: root
    - file_mode: 644
    - template: jinja

/srv/kubernetes/manifests/rook-ceph/kube-prometheus-service-monitor.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://kubernetes/csi/rook-ceph/files/kube-prometheus-service-monitor.yaml
    - user: root
    - group: root
    - file_mode: 644
    - template: jinja

/srv/kubernetes/manifests/rook-ceph/kube-prometheus-grafana-dashboard.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://kubernetes/csi/rook-ceph/files/kube-prometheus-grafana-dashboard.yaml
    - user: root
    - group: root
    - file_mode: 644

/srv/kubernetes/manifests/rook-ceph/rook-ceph-ingress.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://kubernetes/csi/rook-ceph/templates/ingress.yaml.jinja
    - user: root
    - group: root
    - file_mode: 644
    - template: jinja

rook-operator-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/operator.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/operator.yaml

rook-operator-wait:
  cmd.run:
    - require:
      - cmd: rook-operator-install
    - runas: root
    - name: until kubectl -n rook-ceph-system get pods --field-selector=status.phase=Running | grep rook-ceph-operator; do printf 'rook-ceph-operator is not Running' && sleep 5; done
    - use_vt: True
    - timeout: 180

rook-cluster-install:
  cmd.run:
    - require:
      - cmd: rook-operator-wait
      - cmd: rook-operator-install
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/rbac.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/cluster.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/pool.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/object.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/filesystem.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/storageclass.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/dashboard-external.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/rook-ceph-ingress.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/rbac.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/cluster.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/pool.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/object.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/filesystem.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/storageclass.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/dashboard-external.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/rook-ceph-ingress.yaml

rook-cluster-wait:
  cmd.run:
    - require:
      - cmd: rook-cluster-install
    - runas: root
    - name: until kubectl -n rook-ceph get pods --field-selector=status.phase=Running | grep rook-ceph-mgr; do printf 'rook-ceph-mgr is not Running' && sleep 5; done
    - use_vt: True
    - timeout: 180

rook-monitoring-install:
  cmd.run:
    - require:
      - cmd: rook-cluster-wait
      - cmd: rook-cluster-install
    - watch:
      - file: /srv/kubernetes/manifests/rook-ceph/toolbox.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/prometheus.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/prometheus-service.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/service-monitor.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/kube-prometheus-ceph-exporter.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/kube-prometheus-prometheus.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/kube-prometheus-service-monitor.yaml
      - file: /srv/kubernetes/manifests/rook-ceph/kube-prometheus-grafana-dashboard.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/toolbox.yaml
        {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/kube-prometheus-ceph-exporter.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/kube-prometheus-grafana-dashboard.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/kube-prometheus-prometheus.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/kube-prometheus-service-monitor.yaml
        {%- else %}
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/prometheus.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/prometheus-service.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-ceph/service-monitor.yaml
        {%- endif %}