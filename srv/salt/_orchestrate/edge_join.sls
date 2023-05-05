{%- set node_name = salt['pillar.get']('event_originator') -%}
{% set cri_provider = salt['pillar.get']('kubernetes:common:cri:provider') %}

edge_kubeadm_join_edge:
  salt.state:
    - tgt: 'G@role:edge'
    - tgt_type: compound
    - sls: kubernetes.role.edge.kubeadm
    - queue: True

