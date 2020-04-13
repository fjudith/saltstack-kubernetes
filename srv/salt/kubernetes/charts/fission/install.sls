# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import fission with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

/opt/fission-cli-linux-v{{ fission.client_version }}:
  file.managed:
    - source: https://github.com/fission/fission/releases/download/{{ fission.client_version }}/fission-cli-linux
    - skip_verify: true
    - mode: "0755"
    - user: root
    - group: root
    - if_missing: /opt/faas-cli-v{{ fission.client_version }}

/usr/local/bin/fission:
  file.symlink:
    - target: /opt/fission-cli-linux-v{{ fission.client_version }}

fission:
  cmd.run:
    - runas: root
    - require:
      - file: /srv/kubernetes/manifests/fission
    - watch:
        - cmd: fission-namespace
        - cmd: fission-fetch-charts
        - file: /srv/kubernetes/manifests/fission/values.yaml
    - cwd: /srv/kubernetes/manifests/fission/fission-all
    - use_vt: true
    - name: |
        helm dependency update
        helm upgrade --install fission \
          --namespace fission \
          --values /srv/kubernetes/manifests/fission/values.yaml \
          "./" --debug

fission-workflows:
  cmd.run:
    - runas: root
    - require:
      - file: /srv/kubernetes/manifests/fission
    - watch:
        - cmd: fission-namespace
        - cmd: fission-fetch-charts
    - cwd: /srv/kubernetes/manifests/fission/fission-workflows
    - use_vt: true
    - name: |
        helm dependency update
        helm upgrade --install fission-workflows \
          --namespace fission \
          "./" --debug