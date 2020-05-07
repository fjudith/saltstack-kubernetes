# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import istio with context %}

/srv/kubernetes/manifests/istio:
  archive.extracted:
    - source: https://github.com/istio/istio/releases/download/{{ istio.version }}/istio-{{ istio.version }}-linux.tar.gz
    - source_hash: {{ istio.source_hash }}
    - user: root
    - group: root
    - archive_format: tar