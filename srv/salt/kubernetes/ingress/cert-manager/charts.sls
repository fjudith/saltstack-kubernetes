# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import cert_manager with context %}

cert-manager-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/cert-manager/cert-manager

cert-manager-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: cert-manager-remove-charts
      - file: /srv/kubernetes/manifests/cert-manager
    - cwd: /srv/kubernetes/manifests/cert-manager
    - name: |
        helm repo add jetstack https://charts.jetstack.io
        helm fetch --untar jetstack/cert-manager --version v{{ cert_manager.version }}
