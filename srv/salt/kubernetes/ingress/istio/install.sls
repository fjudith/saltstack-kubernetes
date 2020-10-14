# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import istio with context %}

/usr/local/bin/istioctl:
  file.copy:
    - source: /srv/kubernetes/manifests/istio/istio-{{ istio.version }}/bin/istioctl
    - mode: "0555"
    - user: root
    - group: root
    - force: true
    - require:
      - archive: /srv/kubernetes/manifests/istio
    - unless: cmp -s /usr/local/bin/istioctl /srv/kubernetes/manifests/istio/istio-{{ istio.version }}/bin/istioctl

istio-operator:
  cmd.run:
    - watch:
      - file: /usr/local/bin/istioctl
    - user: root
    - group: root
    - name: |
        istioctl operator init
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

istio:
  cmd.run:
    - watch:
      - cmd: istio-operator 
      - file: /srv/kubernetes/manifests/istio/istio-config.yaml
    - user: root
    - group: root
    - name: |       
        kubectl apply -f /srv/kubernetes/manifests/istio/istio-config.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

istio-kiali:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/istio/istio-{{ istio.version }}
    - watch:
      - cmd: istio-operator
    - user: root
    - group: root
    - name: |       
        kubectl apply -f samples/addons/kiali.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

istio-jaeger:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/istio/istio-{{ istio.version }}
    - watch:
      - cmd: istio 
    - user: root
    - group: root
    - name: |       
        kubectl apply -f samples/addons/jaeger.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

istio-prometheus:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/istio/istio-{{ istio.version }}
    - watch:
      - cmd: istio 
    - user: root
    - group: root
    - name: |       
        kubectl apply -f samples/addons/prometheus.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

istio-grafana:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/istio/istio-{{ istio.version }}
    - watch:
      - cmd: istio 
    - user: root
    - group: root
    - name: |       
        kubectl apply -f samples/addons/grafana.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
