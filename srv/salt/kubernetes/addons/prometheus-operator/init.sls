{%- from "kubernetes/map.jinja" import common with context -%}

addon-prometheus-operator:
  git.latest:
    - name: https://github.com/coreos/prometheus-operator
    - target: /srv/kubernetes/manifests/prometheus-operator
    - force_reset: True
    - rev: {{ common.addons.kube_prometheus.version }}

/srv/kubernetes/manifests/kube-prometheus-ingress.yaml:
    file.managed:
    - source: salt://kubernetes/addons/prometheus-operator/templates/ingress.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - watch:
      - git: addon-prometheus-operator

/srv/kubernetes/manifests/grafana-deployment.yaml:
    file.managed:
    - source: salt://kubernetes/addons/prometheus-operator/templates/grafana-deployment.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - watch:
      - git: addon-prometheus-operator

kubernetes-kube-prometheus-install:
  cmd.run:
    - watch:
        - git:  addon-prometheus-operator
        - file: /srv/kubernetes/manifests/kube-prometheus-ingress.yaml
        - file: /srv/kubernetes/manifests/grafana-deployment.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/prometheus-operator/contrib/kube-prometheus/manifests/ || true
        kubectl apply -f /srv/kubernetes/manifests/prometheus-operator/contrib/kube-prometheus/manifests/ 2>/dev/null || true
        kubectl apply -f /srv/kubernetes/manifests/grafana-deployment.yaml
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus-ingress.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
