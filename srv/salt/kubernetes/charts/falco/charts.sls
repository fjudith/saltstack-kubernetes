# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import falco with context %}

falco-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/falco/falco

falco-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: falco-remove-charts
      - file: /srv/kubernetes/manifests/falco
    - cwd: /srv/kubernetes/manifests/falco
    - name: |
        helm fetch --untar stable/falco

falco-exporter-fetch-charts:
  git.latest:
    - require:
      - file: /srv/kubernetes/manifests/falco
    - name: https://github.com/falcosecurity/falco-exporter
    - target: /srv/kubernetes/manifests/falco/falco-exporter
    - force_reset: True
    - rev: v{{ falco.exporter_version }}