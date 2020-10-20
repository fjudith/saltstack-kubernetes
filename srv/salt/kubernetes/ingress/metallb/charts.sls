# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import metallb with context %}

metallb-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/metallb/metallb

metallb-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: metallb-remove-charts
      - file: /srv/kubernetes/manifests/metallb
    - cwd: /srv/kubernetes/manifests/metallb
    - name: |
        helm repo add bitnami https://charts.bitnami.com/bitnami
        helm fetch --untar bitnami/metallb
