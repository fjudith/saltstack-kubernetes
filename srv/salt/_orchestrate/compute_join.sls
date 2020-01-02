{%- set node_name = salt['pillar.get']('event_originator') -%}

compute_common_state:
  salt.state:
    - tgt: 'G@role:node'
    - tgt_type: compound
    - sls: common
    - queue: True

compute_docker_state:
  salt.state:
    - tgt: 'G@role:node'
    - tgt_type: compound
    - sls: kubernetes.cri.docker
    - queue: True

compute_kubeadm_join_node:
  salt.state:
    - tgt: 'G@role:node'
    - tgt_type: compound
    - sls: kubernetes.role.node.kubeadm
    - queue: True
    - require:
      - salt: compute_common_state
      - salt: compute_docker_state
