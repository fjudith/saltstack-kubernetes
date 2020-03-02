# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{%- from tpldir ~ "/map.jinja" import containerd with context %}

/tmp/containerd-v{{ containerd.version }}:
  archive.extracted:
    - source: https://github.com/containerd/containerd/releases/download/v{{ containerd.version }}/containerd-{{ containerd.version }}.linux-amd64.tar.gz
    - source_hash: {{ containerd.source_hash }}
    - archive_format: tar

containerd:
  service.dead:
    - name: containerd.service
    - watch:
      - archive: /tmp/containerd-v{{ containerd.version }}
    - unless: cmp -s /usr/local/bin/containerd /tmp/containerd-v{{ containerd.version }}/bin/containerd
  file.copy:
    - name: /usr/local/bin
    - source: /tmp/containerd-v{{ containerd.version }}/bin
    - user: root
    - group: root
    - mode: 555
    - unless: cmp -s /usr/local/bin/containerd /tmp/containerd-v{{ containerd.version }}/bin/containerd
