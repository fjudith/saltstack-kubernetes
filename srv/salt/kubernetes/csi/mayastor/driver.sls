# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import mayastor with context %}

mayastor-csi-driver:
  cmd.run:
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
    - name: |
        kubectl apply -f {{ mayastor.csi_driver }}
        kubectl apply -f {{ mayastor.csi_nodeinfo }}