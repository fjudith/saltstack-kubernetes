# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import portworx with context %}

portworx:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/portworx
    - name: /srv/kubernetes/manifests/portworx/portworx.yaml
    - source: {{ portworx.manifest_url }}
    - skip_verify: true
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/portworx/portworx.yaml
      - cmd: portworx-namespace
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/portworx/portworx.yaml