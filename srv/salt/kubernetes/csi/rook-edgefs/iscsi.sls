# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import rook_edgefs with context %}

rook-edgefs-iscsi-config:
  cmd.run:
    - require:
      - cmd: rook-edgefs-system-init
    - runas: root
    - use_vt: True
    - timeout: 180
    - success_retcodes: [0, 1]
    - name: |
        kubectl exec -it -n rook-edgefs $(kubectl -n rook-edgefs -l app=rook-edgefs-mgr get po -o jsonpath='{range .items[*]}{.metadata.name}') -- toolbox \
          efscli bucket create {{ rook_edgefs.cluster }}/{{ rook_edgefs.tenant }}/{{ rook_edgefs.iscsi_service }}
        
        kubectl exec -it -n rook-edgefs $(kubectl -n rook-edgefs -l app=rook-edgefs-mgr get po -o jsonpath='{range .items[*]}{.metadata.name}') -- toolbox \
          efscli service create iscsi {{ rook_edgefs.iscsi_service }}

        kubectl exec -it -n rook-edgefs $(kubectl -n rook-edgefs -l app=rook-edgefs-mgr get po -o jsonpath='{range .items[*]}{.metadata.name}') -- toolbox \
          efscli service serve {{ rook_edgefs.iscsi_service }} {{ rook_edgefs.cluster }}/{{ rook_edgefs.tenant }}/{{ rook_edgefs.iscsi_service }}/lun0

rook-edgefs-iscsi:
  file.managed:
    - require:
      - cmd: rook-edgefs-iscsi-config
      - file: /srv/kubernetes/manifests/rook-edgefs
    - name: /srv/kubernetes/manifests/rook-edgefs/iscsi.yaml
    - source: salt://{{ tpldir }}/templates/iscsi.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/rook-edgefs/iscsi.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/iscsi.yaml

rook-edgefs-iscsi-driver-config:
  file.managed:
    - require:
      - cmd: rook-edgefs-iscsi
      - file: /srv/kubernetes/manifests/rook-edgefs
    - name: /srv/kubernetes/manifests/rook-edgefs/edgefs-iscsi-csi-driver-config.yaml
    - source: salt://{{ tpldir }}/templates/edgefs-iscsi-csi-driver-config.yaml.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs/edgefs-iscsi-csi-driver-config.yaml
    - runas: root
    - name: |  
        kubectl get secret edgefs-iscsi-csi-driver-config || \
        kubectl create secret generic edgefs-iscsi-csi-driver-config --from-file=/srv/kubernetes/manifests/rook-edgefs/edgefs-iscsi-csi-driver-config.yaml

rook-edgefs-iscsi-driver:
  file.managed:
    - require:
      - cmd: rook-edgefs-iscsi-driver-config
      - file: /srv/kubernetes/manifests/rook-edgefs
    - name: /srv/kubernetes/manifests/rook-edgefs/edgefs-iscsi-csi-driver.yaml
    - source: salt://{{ tpldir }}/files/edgefs-iscsi-csi-driver.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs/edgefs-iscsi-csi-driver.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/edgefs-iscsi-csi-driver.yaml