# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import openebs with context %}

openebs-csi-driver:
  cmd.run:
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: |
        kubectl apply -f {{ openebs.csi_driver }}
        kubectl apply -f {{ openebs.csi_nodeinfo }}