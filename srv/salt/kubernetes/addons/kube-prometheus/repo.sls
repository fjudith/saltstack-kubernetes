{%- from "kubernetes/map.jinja" import common with context -%}

kube-prometheus-repo:
  git.latest:
    - name: https://github.com/coreos/kube-prometheus
    - target: /srv/kubernetes/manifests/kube-prometheus
    - force_reset: True
    - rev: v{{ common.addons.kube_prometheus.version }}