# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import fission with context %}

fission-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/fission/fission-all

fission-workflows-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/fission/fission-workflows

fission-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: fission-remove-charts
      - file: fission-workflows-remove-charts
      - file: /srv/kubernetes/manifests/fission
    - cwd: /srv/kubernetes/manifests/fission
    - name: |
        helm repo add fission https://fission.github.io/fission-charts/
        helm fetch --untar fission/fission-all --version v{{ fission.version }}
        helm fetch --untar fission/fission-workflows --version v{{ fission.workflows_version }}
