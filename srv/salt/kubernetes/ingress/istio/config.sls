# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import istio with context %}

/srv/kubernetes/manifests/istio:
  archive.extracted:
    - source: https://github.com/istio/istio/releases/download/{{ istio.version }}/istio-{{ istio.version }}-linux-amd64.tar.gz
    - source_hash: {{ istio.source_hash }}
    - user: root
    - group: root
    - archive_format: tar

/srv/kubernetes/manifests/istio/istio-config.yaml:
  file.managed:
    - require:
      - archive: /srv/kubernetes/manifests/istio
    - source: salt://{{ tpldir }}/templates/istio-config.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}