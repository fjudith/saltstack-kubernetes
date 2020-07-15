{%- set node_name = salt['pillar.get']('event_originator') -%}

etcd_state:
  salt.state:
    - tgt: 'role:etcd'
    - tgt_type: grain
    - sls: kubernetes.role.etcd
    - queue: True
    - require:
      - salt: common_state
