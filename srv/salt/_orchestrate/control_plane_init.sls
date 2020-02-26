{%- set node_name = salt['pillar.get']('event_originator') -%}

control_plane_primary_common_state:
  salt.state:
    - tgt: 'master01'
    - sls: common
    - queue: True

control_plane_primary_docker_state:
  salt.state:
    - tgt: 'master01'
    - sls: kubernetes.cri.docker
    - queue: True

control_plane_primary_kubeadm_init:
  salt.state:
    - tgt: 'master01'
    - sls: kubernetes.role.master.kubeadm.init
    - queue: True
    - require:
      - salt: control_plane_primary_common_state
      - salt: control_plane_primary_docker_state