{%- set node_name = salt['pillar.get']('event_originator') -%}
{%- set masters = [] -%}
{%- for key, value in salt["saltutil.runner"]('mine.get', tgt="role:master", fun="network.get_hostname", tgt_type="grain")|dictsort(false, 'value') -%}
  {%- do masters.append(value) -%}
{%- endfor -%}

{% if masters|length < 1 %}
{{ raise('ERROR: at least one master must be specified') }}
{% endif %}

{% set cri_provider = salt['pillar.get']('kubernetes:common:cri:provider') %}

control_plane_primary_kubeadm_init:
  salt.state:
    - tgt: "{{ masters|first }}"
    - sls: kubernetes.role.master.kubeadm
    - queue: True
    # - require:
    #   - salt: common_state
    #   - salt: {{ cri_provider }}_state
    #   - salt: etcd_state
    #   {%- if salt['pillar.get']('haproxy', {'enabled': False}).enabled %}
    #   - salt: edge_haproxy_state
    #   {%- elif salt['pillar.get']('envoy', {'enabled': False}).enabled %}
    #   - salt: edge_envoy_state
    #   {%- endif %}
    # - require_in:
    #     - salt: control_plane_kubeadm_join_master
    #     - salt: edge_kubeadm_join_edge
    #     - salt: compute_kubeadm_join_node
