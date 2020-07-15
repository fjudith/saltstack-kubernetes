{%- set node_name = salt['pillar.get']('event_originator') -%}

edge_kubeadm_join_edge:
  salt.state:
    - tgt: 'G@role:edge'
    - tgt_type: compound
    - sls: kubernetes.role.edge.kubeadm
    - queue: True
    - require:
      - salt: common_state
      - salt: docker_state
      - salt: compute_kubeadm_join_node
