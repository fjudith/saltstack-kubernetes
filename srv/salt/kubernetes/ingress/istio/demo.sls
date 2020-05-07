# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import istio with context %}

istio-bookinfo:
  file.managed:
    - name: /srv/kubernetes/manifests/istio/bookinfo-ingress.yaml
    - source: salt://{{ tpldir }}/templates/bookinfo-ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - cwd: /srv/kubernetes/manifests/istio/istio-{{ istio.version }}
    - watch:
      - cmd: istio-gateway-certificate
      - file: /srv/kubernetes/manifests/istio/bookinfo-ingress.yaml
    - name: | 
        kubectl apply -n bookinfo -f samples/bookinfo/platform/kube/bookinfo.yaml
        kubectl apply -n bookinfo -f /srv/kubernetes/manifests/istio/bookinfo-ingress.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'