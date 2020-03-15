# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import rook_edgefs with context %}
{%- set public_domain = pillar['public-domain'] -%}

rook-edgefs-s3-config:
  cmd.run:
    - require:
      - cmd: rook-edgefs-system-init
    - runas: root
    - use_vt: True
    - timeout: 180
    - name: |
        kubectl exec -it -n rook-edgefs $(kubectl -n rook-edgefs -l app=rook-edgefs-mgr get po -o jsonpath='{range .items[*]}{.metadata.name}') -- toolbox \
          efscli bucket create {{ rook_edgefs.cluster }}/{{ rook_edgefs.tenant }}/{{ rook_edgefs.s3_service }}
        
        kubectl exec -it -n rook-edgefs $(kubectl -n rook-edgefs -l app=rook-edgefs-mgr get po -o jsonpath='{range .items[*]}{.metadata.name}') -- toolbox \
          efscli service create s3 {{ rook_edgefs.s3_service }}

        kubectl exec -it -n rook-edgefs $(kubectl -n rook-edgefs -l app=rook-edgefs-mgr get po -o jsonpath='{range .items[*]}{.metadata.name}') -- toolbox \
          efscli service serve {{ rook_edgefs.s3_service }} {{ rook_edgefs.cluster }}/{{ rook_edgefs.tenant }}/{{ rook_edgefs.s3_service }}

        kubectl exec -it -n rook-edgefs $(kubectl -n rook-edgefs -l app=rook-edgefs-mgr get po -o jsonpath='{range .items[*]}{.metadata.name}') -- toolbox \
          efscli service config {{ rook_edgefs.s3_service }} X-Domain {{ rook_edgefs.s3_service }}.{{ public_domain }}

rook-edgefs-s3-driver:
  file.managed:
    - require:
      - cmd: rook-edgefs-s3-config
      - file: /srv/kubernetes/manifests/rook-edgefs
    - name: /srv/kubernetes/manifests/rook-edgefs/s3.yaml
    - source: salt://{{ tpldir }}/templates/s3.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/rook-edgefs/s3.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/s3.yaml
  