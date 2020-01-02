{%- set node_name = salt['pillar.get']('event_originator') -%}

edge_common_state:
  salt.state:
    - tgt: 'role:proxy'
    - tgt_type: grain
    - sls: common
    - queue: True

edge_docker_state:
  salt.state:
    - tgt: 'G@role:proxy'
    - tgt_type: compound
    - sls: kubernetes.cri.docker
    - queue: True

edge_kubeadm_join_proxy:
  salt.state:
    - tgt: 'G@role:proxy'
    - tgt_type: compound
    - sls: kubernetes.role.proxy.kubeadm
    - queue: True
    - require:
      - salt: edge_common_state
      - salt: edge_docker_state
