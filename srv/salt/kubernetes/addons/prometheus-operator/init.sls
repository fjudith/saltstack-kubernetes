{%- from "kubernetes/map.jinja" import common with context -%}

addon-prometheus-operator:
  git.latest:
    - name: https://github.com/coreos/prometheus-operator
    - target: /srv/kubernetes/manifests/prometheus-operator
    - force_reset: True
    - rev: v0.23.1

/srv/kubernetes/manifests/prometheus-operator/contrib/kube-prometheus/manifests/kube-prometheus-ingress.yaml:
    file.managed:
    - source: salt://kubernetes/addons/prometheus-operator/kube-prometheus-ingress.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - watch:
      - git: addon-prometheus-operator

/srv/kubernetes/manifests/prometheus-operator/contrib/kube-prometheus/manifests/grafana-deployment.yaml:
    file.managed:
    - source: salt://kubernetes/addons/prometheus-operator/grafana-deployment.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - watch:
      - git: addon-prometheus-operator

kubernetes-kube-prometheus-install:
  cmd.run:
    - require:
      - cmd: kubernetes-wait
    - watch:
        - git:  addon-prometheus-operator
        - file: /srv/kubernetes/manifests/prometheus-operator/contrib/kube-prometheus/manifests/kube-prometheus-ingress.yaml
        - file: /srv/kubernetes/manifests/prometheus-operator/contrib/kube-prometheus/manifests/grafana-deployment.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/prometheus-operator/contrib/kube-prometheus/manifests/