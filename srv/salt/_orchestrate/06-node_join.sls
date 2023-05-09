{%- set node_name = salt['pillar.get']('event_originator') -%}
{% set cri_provider = salt['pillar.get']('kubernetes:common:cri:provider') %}

node-cri:
  salt.state:
    - tgt: 'G@role:node'
    - tgt_type: compound
    - sls: kubernetes.cri.{{ cri_provider }}
    - queue: True

node-kubeadm_join:
  salt.state:
    - tgt: 'G@role:node'
    - tgt_type: compound
    - sls: kubernetes.role.node.kubeadm
    - queue: True
    - require:
      - salt: loopback-iscsi
      - salt: envoy
      - salt: control-plane-kubeadm_init
      - salt: node-cri
