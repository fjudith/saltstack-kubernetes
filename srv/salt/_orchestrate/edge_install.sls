{%- set node_name = salt['pillar.get']('event_originator') -%}

edge_haproxy_state:
  salt.state:
    - tgt: 'role:edge'
    - tgt_type: grain
    - sls: haproxy
    - queue: True
