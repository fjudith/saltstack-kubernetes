{%- set node_name = salt['pillar.get']('event_originator') -%}

control_plane_common_state:
  salt.state:
    - tgt: 'G@role:master and not L@master01'
    - tgt_type: compound
    - sls: common
    - queue: True

control_plane_docker_state:
  salt.state:
    - tgt: 'G@role:master and not L@master01'
    - tgt_type: compound
    - sls: kubernetes.cri.docker
    - queue: True

control_plane_kubeadm_join_master:
  salt.state:
    - tgt: 'G@role:master and not L@master01'
    - tgt_type: compound
    - sls: kubernetes.role.master.kubeadm.join
    - queue: True
    - require:
      - salt: control_plane_common_state
      - salt: control_plane_docker_state