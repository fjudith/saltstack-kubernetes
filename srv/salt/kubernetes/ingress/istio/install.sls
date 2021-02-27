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
    - name: istioctl operator init
    - onlyif: http --verify false https://localhost:6443/livez?verbose

istio:
  cmd.run:
    - watch:
      - cmd: istio-operator 
      - file: /srv/kubernetes/manifests/istio/istio-config.yaml
    - name: kubectl apply -f /srv/kubernetes/manifests/istio/istio-config.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose