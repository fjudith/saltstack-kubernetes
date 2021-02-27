# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import cert_manager with context %}

cert-manager-crds:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/cert-manager/00-crds.yaml
    - runas: root
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: kubectl apply -f /srv/kubernetes/manifests/cert-manager/00-crds.yaml

{% if cert_manager.get('dns', {'enabled': False}).enabled and cert_manager.dns.provider == 'cloudflare'%}
cert-manager-cloudflare-secret:
  cmd.run:
    - runas: root
    - name: |
        kubectl -n cert-manager delete secret public-dns-secret
        kubectl -n cert-manager create secret generic public-dns-secret --from-literal=secret-access-key="{{ cert_manager.dns.cloudflare.secret }}"
{% endif %}

cert-manager:
  cmd.run:
    - runas: root
    - watch:
      - cmd: cert-manager-namespace
      - cmd: cert-manager-fetch-charts
    - cwd: /srv/kubernetes/manifests/cert-manager/cert-manager
    - name: |
        helm upgrade --install cert-manager --namespace cert-manager \
            "./" --wait --timeout 5m

query-cert-manager-api:
  cmd.run:
    - name: |
        http --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/cert-manager.io | grep -niE "apigroup"
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10

cert-manager-clusterissuer:
  cmd.run:
    - require:
      - cmd: query-cert-manager-api
    - watch:
        - file: /srv/kubernetes/manifests/cert-manager/clusterissuer.yaml
    - runas: root
    - onlyif: |
        http --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/cert-manager.io
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/cert-manager/clusterissuer.yaml
