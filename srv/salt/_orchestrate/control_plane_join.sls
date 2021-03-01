{%- set node_name = salt['pillar.get']('event_originator') -%}
{%- set masters = [] -%}
{%- for key, value in salt["saltutil.runner"]('mine.get', tgt="role:master", fun="network.get_hostname", tgt_type="grain")|dictsort(false, 'value') -%}
  {%- do masters.append(value) -%}
{%- endfor -%}

{% if masters|length > 1 %}

{% set cri_provider = salt['pillar.get']('kubernetes:common:cri:provider') %}

control_plane_kubeadm_join_master:
  salt.state:
    - tgt: "{{ masters[1:]|join(",") }}"
    - tgt_type: "list"
    - sls: kubernetes.role.master.kubeadm
    - queue: True
    - batch: 1
    - require:
      - salt: common_state
      - salt: {{ cri_provider }}_state
      - salt: control_plane_primary_kubeadm_init
{% endif %}