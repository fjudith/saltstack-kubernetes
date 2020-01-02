{%- set node_name = salt['pillar.get']('event_originator') -%}

etcd_common_state:
  salt.state:
    - tgt: 'role:etcd'
    - tgt_type: grain
    - sls: common
    - queue: True

etcd_state:
  salt.state:
    - tgt: 'role:etcd'
    - tgt_type: grain
    - sls: kubernetes.role.etcd
    - queue: True
    - require:
      - salt: etcd_common_state
