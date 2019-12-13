{%- from "kubernetes/map.jinja" import common with context -%}

addon-kube-prometheus:
  git.latest:
    - name: https://github.com/coreos/kube-prometheus
    - target: /srv/kubernetes/manifests/kube-prometheus
    - force_reset: True
    - rev: v{{ common.addons.kube_prometheus.version }}

/srv/kubernetes/manifests/kube-prometheus/manifests/ingress.yaml:
    file.managed:
    - source: salt://kubernetes/addons/kube-prometheus/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - watch:
      - git: addon-kube-prometheus

/srv/kubernetes/manifests/kube-prometheus/manifests/grafana-deployment.yaml:
    file.managed:
    - source: salt://kubernetes/addons/kube-prometheus/templates/grafana-deployment.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - watch:
      - git: addon-kube-prometheus

kubernetes-kube-prometheus-install:
  cmd.run:
    - watch:
        - git:  addon-kube-prometheus
        - file: /srv/kubernetes/manifests/kube-prometheus/manifests/ingress.yaml
        - file: /srv/kubernetes/manifests/kube-prometheus/manifests/grafana-deployment.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/manifests/   
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

kubernetes-kube-prometheus-grafana:
  cmd.run:
    - watch:
        - cmd: kubernetes-kube-prometheus-install
        - file: /srv/kubernetes/manifests/kube-prometheus/manifests/grafana-deployment.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/manifests/grafana-deployment.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

kubernetes-kube-prometheus-ingress:
  cmd.run:
    - watch:
        - cmd: kubernetes-kube-prometheus-install
        - file: /srv/kubernetes/manifests/kube-prometheus/manifests/ingress.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/manifests/ingress.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

query-kube-prometheus-required-api:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:8080/apis/monitoring.coreos.com'
    - match: monitoring.coreos.com
    - wait_for: 180
    - request_interval: 5
    - status: 200