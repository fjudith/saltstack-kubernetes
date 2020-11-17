{%- set node_name = salt['pillar.get']('event_originator') -%}

{%- if salt['pillar.get']('haproxy', {'enabled': False}).enabled %}
edge_haproxy_state:
  salt.state:
    - tgt: 'role:edge'
    - tgt_type: grain
    - sls: haproxy
    - queue: True

{%- elif salt['pillar.get']('envoy', {'enabled': False}).enabled %}

edge_envoy_state:
  salt.state:
    - tgt: 'role:edge'
    - tgt_type: grain
    - sls: envoy
    - queue: True

{%- endif %}