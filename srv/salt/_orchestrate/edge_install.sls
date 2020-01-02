{%- set node_name = salt['pillar.get']('event_originator') -%}

edge_haproxy_state:
  salt.state:
    - tgt: 'role:proxy'
    - tgt_type: grain
    - sls: haproxy
    - queue: True
