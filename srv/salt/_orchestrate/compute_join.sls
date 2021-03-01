{%- set node_name = salt['pillar.get']('event_originator') -%}
{% set cri_provider = salt['pillar.get']('kubernetes:common:cri:provider') %}

compute_kubeadm_join_node:
  salt.state:
    - tgt: 'G@role:node'
    - tgt_type: compound
    - sls: kubernetes.role.node.kubeadm
    - queue: True
    - require:
      - salt: common_state
      - salt: {{ cri_provider }}_state
      - salt: control_plane_kubeadm_join_master
