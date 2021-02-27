# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import istio with context %}

istio-kiali:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/istio/istio-{{ istio.version }}
    - watch:
      - cmd: istio
    - name: kubectl apply -f samples/addons/kiali.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose

istio-jaeger:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/istio/istio-{{ istio.version }}
    - watch:
      - cmd: istio 
    - name: kubectl apply -f samples/addons/jaeger.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose

istio-prometheus:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/istio/istio-{{ istio.version }}
    - watch:
      - cmd: istio 
    - name: kubectl apply -f samples/addons/prometheus.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose

istio-grafana:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/istio/istio-{{ istio.version }}
    - watch:
      - cmd: istio
    - name: kubectl apply -f samples/addons/grafana.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose
