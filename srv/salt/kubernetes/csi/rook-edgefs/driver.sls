# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import rook_edgefs with context %}

rook-edgefs-csi-driver:
  cmd.run:
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: |
        kubectl apply -f {{ rook_edgefs.csi_driver }}
        kubectl apply -f {{ rook_edgefs.csi_nodeinfo }}