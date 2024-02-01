{%- set node_name = salt['pillar.get']('event_originator') -%}
{% set cri_provider = salt['pillar.get']('kubernetes:common:cri:provider') %}

edge-cri:
  salt.state:
    - tgt: 'G@role:edge'
    - tgt_type: compound
    - sls: kubernetes.cri.{{ cri_provider }}
    - queue: True

edge-kubeadm_join:
  salt.state:
    - tgt: 'G@role:edge'
    - tgt_type: compound
    - sls: kubernetes.role.edge.kubeadm
    - queue: True
    - require:
      - salt: envoy
      - salt: control-plane-kubeadm_init
      - salt: edge-cri
