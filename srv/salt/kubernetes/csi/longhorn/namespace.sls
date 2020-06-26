# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import longhorn with context %}

longhorn-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/longhorn
    - name: /srv/kubernetes/manifests/longhorn/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/longhorn/namespace.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/longhorn/namespace.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'