# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import mayastor with context %}

mayastor-csi-driver:
  cmd.run:
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: |
        kubectl apply -f {{ mayastor.csi_driver }}
        kubectl apply -f {{ mayastor.csi_nodeinfo }}