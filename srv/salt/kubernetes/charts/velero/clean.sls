# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import velero with context %}

velero-teardown:
  cmd.run:
    - runas: root
    - cwd: /srv/kubernetes/manifests/velero/velero
    - name: |
        velero backup delete nginx-backup --confirm
        velero backup delete nginx-daily --confirm
        helm delete -n velero velero
        kubectl delete -f crds/

        
        