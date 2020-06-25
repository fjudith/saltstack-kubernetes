# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import rook_edgefs with context %}

rook-edgefs-nfs-config:
  cmd.run:
    - require:
      - cmd: rook-edgefs-system-init
    - runas: root
    - timeout: 180
    - success_retcodes: [0, 1]
    - name: |
        kubectl exec -it -n rook-edgefs $(kubectl -n rook-edgefs -l app=rook-edgefs-mgr get po -o jsonpath='{range .items[*]}{.metadata.name}') -- toolbox \
          efscli bucket create {{ rook_edgefs.cluster }}/{{ rook_edgefs.tenant }}/{{ rook_edgefs.nfs_service }}
        
        kubectl exec -it -n rook-edgefs $(kubectl -n rook-edgefs -l app=rook-edgefs-mgr get po -o jsonpath='{range .items[*]}{.metadata.name}') -- toolbox \
          efscli service create nfs {{ rook_edgefs.nfs_service }}

        kubectl exec -it -n rook-edgefs $(kubectl -n rook-edgefs -l app=rook-edgefs-mgr get po -o jsonpath='{range .items[*]}{.metadata.name}') -- toolbox \
          efscli service serve {{ rook_edgefs.nfs_service }} {{ rook_edgefs.cluster }}/{{ rook_edgefs.tenant }}/{{ rook_edgefs.nfs_service }}

rook-edgefs-nfs:
  file.managed:
    - require:
      - cmd: rook-edgefs-nfs-config
      - file: /srv/kubernetes/manifests/rook-edgefs
    - name: /srv/kubernetes/manifests/rook-edgefs/nfs.yaml
    - source: salt://{{ tpldir }}/templates/nfs.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/rook-edgefs/nfs.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/nfs.yaml

rook-edgefs-nfs-driver-config:
  file.managed:
    - require:
      - cmd: rook-edgefs-nfs
      - file: /srv/kubernetes/manifests/rook-edgefs
    - name: /srv/kubernetes/manifests/rook-edgefs/edgefs-nfs-csi-driver-config.yaml
    - source: salt://{{ tpldir }}/templates/edgefs-nfs-csi-driver-config.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs/edgefs-nfs-csi-driver-config.yaml
    - runas: root
    - name: |  
        kubectl -n rook-edgefs get secret edgefs-nfs-csi-driver-config || \
        kubectl -n rook-edgefs create secret generic edgefs-nfs-csi-driver-config --from-file=/srv/kubernetes/manifests/rook-edgefs/edgefs-nfs-csi-driver-config.yaml

rook-edgefs-nfs-driver:
  file.managed:
    - require:
      - cmd: rook-edgefs-nfs-driver-config
      - file: /srv/kubernetes/manifests/rook-edgefs
    - name: /srv/kubernetes/manifests/rook-edgefs/edgefs-nfs-csi-driver.yaml
    - source: salt://{{ tpldir }}/files/edgefs-nfs-csi-driver.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs/edgefs-nfs-csi-driver.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/edgefs-nfs-csi-driver.yaml
  