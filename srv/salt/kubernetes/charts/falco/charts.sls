# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import falco with context %}

falco-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/falco/falco

falco-exporter-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/falco/falco-exporter

falco-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: falco-remove-charts
      - file: /srv/kubernetes/manifests/falco
    - cwd: /srv/kubernetes/manifests/falco
    - name: |
        helm repo add falcosecurity https://falcosecurity.github.io/charts
        helm fetch --untar falcosecurity/falco

falco-exporter-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: falco-exporter-remove-charts
      - file: /srv/kubernetes/manifests/falco
      - cmd: falco-fetch-charts
    - cwd: /srv/kubernetes/manifests/falco
    - name: |
        helm fetch --untar falcosecurity/falco-exporter
    