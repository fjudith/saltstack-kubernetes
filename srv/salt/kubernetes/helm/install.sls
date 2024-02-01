# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import helm with context %}

/tmp/helm-v{{ helm.version }}:
  archive.extracted:
    - source: https://get.helm.sh/helm-v{{ helm.version }}-linux-amd64.tar.gz
    - source_hash: {{ helm.source_hash }}
    - user: root
    - group: root
    - archive_format: tar
    - enforce_toplevel: false

/usr/local/bin/helm:
  file.copy:
    - source: /tmp/helm-v{{ helm.version }}/linux-amd64/helm
    - mode: "0555"
    - user: root
    - group: root
    - force: true
    - require:
      - archive: /tmp/helm-v{{ helm.version }}
    - unless: cmp -s /usr/local/bin/helm /tmp/helm-v{{ helm.version }}/linux-amd64/helm