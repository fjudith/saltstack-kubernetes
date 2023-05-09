# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import cilium with context %}

{% set state = 'absent' %}
{% set file_state = 'absent' %}
{% if cilium.enabled %}
  {% set state = 'present' %}
  {% set file_state = 'managed' %}
{% endif %}

cilium-cli:
  archive.extracted:
    - name: /usr/local/cilium/{{ cilium.cli_version }}
    - source: https://github.com/cilium/cilium-cli/releases/download/v{{ cilium.cli_version }}/cilium-linux-amd64.tar.gz
    - source_hash: https://github.com/cilium/cilium-cli/releases/download/v{{ cilium.cli_version }}/cilium-linux-amd64.tar.gz.sha256sum
    - skip_verify: false
    - archive_format: tar
    - enforce_toplevel: false
  file.symlink:
    - name: /usr/local/bin/cilium
    - target: /usr/local/cilium/{{ cilium.cli_version }}/cilium
  cmd.run:
    - name: |
        /usr/local/bin/cilium install \
        --version {{ cilium.version }} \
        --helm-set cni.install=true \
        --helm-set cni.chainingMode=portmap

# cilium:
#   file.{{ file_state }}:
#     - require:
#       - file:  /srv/kubernetes/charts/cilium
#     - name: /srv/kubernetes/charts/cilium/values.yaml
#     - source: salt://{{ tpldir }}/templates/values.yaml.j2
#     - user: root
#     - group: root
#     - mode: "0644"
#     - template: jinja
#     - context:
#         tpldir: {{ tpldir }}
#   helm.release_{{ state }}:
#     - watch:
#       - file: /srv/kubernetes/charts/cilium/values.yaml
#     - name: cilium
#     {%- if cilium.enabled %}
#     - chart: cilium/cilium
#     - values: /srv/kubernetes/charts/cilium/values.yaml
#     - version: {{ cilium.chart_version }}
#     - flags:
#       - create-namespace
#     {%- endif %}
#     - namespace: kube-system