{%- set node_name = salt['pillar.get']('event_originator') -%}

compute_kubeadm_join_node:
  salt.state:
    - tgt: 'G@role:node'
    - tgt_type: compound
    - sls: kubernetes.role.node.kubeadm
    - queue: True
    - require:
      - salt: common_state
      - salt: docker_state
      - salt: control_plane_kubeadm_join_master
