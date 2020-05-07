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

istio-cni:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/istio/istio-{{ istio.version }}
    - watch:
      - archive: /srv/kubernetes/manifests/istio
    - user: root
    - group: root
    - name: |
        helm template install/kubernetes/helm/istio-cni \
          --namespace kube-system | kubectl apply -f -
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

istio-init:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/istio/istio-{{ istio.version }}
    - watch:
      - cmd: istio-namespace
      - cmd: istio-cni
      - archive: /srv/kubernetes/manifests/istio
    - user: root
    - group: root
    - name: |       
        helm template install/kubernetes/helm/istio-init \
          --namespace istio-system | kubectl apply -f -
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

istio:
  cmd.run: 
    - cwd: /srv/kubernetes/manifests/istio/istio-{{ istio.version }}
    - watch:
      - cmd: istio-init 
      - archive: /srv/kubernetes/manifests/istio
    - user: root
    - group: root
    - name: |       
        helm template install/kubernetes/helm/istio \
          --namespace istio-system \
          -f install/kubernetes/helm/istio/values-istio-demo.yaml \
          --set tracing.enabled=true \
          --set istio_cni.enabled=true \
          --set kiali.enabled=true \
          --set gateways.istio-ingressgateway.sds.enabled=true \
          --set global.k8sIngress.enabled=true \
          --set global.k8sIngress.enableHttps=true \
          --set global.k8sIngress.gatewayName=ingressgateway \
          --set istio_cni.enabled=true | kubectl apply --namespace istio-system -f -
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'


