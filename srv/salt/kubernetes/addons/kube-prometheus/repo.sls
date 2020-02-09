# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import kube_prometheus with context %}

kube-prometheus-repo:
  git.latest:
    - name: https://github.com/coreos/kube-prometheus
    - target: /srv/kubernetes/manifests/kube-prometheus
    - force_reset: True
    - rev: v{{ kube_prometheus.version }}