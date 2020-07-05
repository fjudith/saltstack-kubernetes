{%- set node_name = salt['pillar.get']('event_originator') -%}
{%- set masters = [] -%}
{%- for key, value in salt["saltutil.runner"]('mine.get', tgt="role:master", fun="network.get_hostname", tgt_type="grain")|dictsort(false, 'value') -%}
  {%- do masters.append(value) -%}
{%- endfor -%}

{% if masters|length < 1 %}
{{ raise('ERROR: at least one master must be specified') }}
{% endif %}

control_plane_primary_common_state:
  salt.state:
    - tgt: "{{ masters|first }}"
    - sls: common
    - queue: True

control_plane_primary_docker_state:
  salt.state:
    - tgt: "{{ masters|first }}"
    - sls: kubernetes.cri.docker
    - queue: True

control_plane_primary_kubeadm_init:
  salt.state:
    - tgt: "{{ masters|first }}"
    - sls: kubernetes.role.master.kubeadm
    - queue: True
    - require:
      - salt: control_plane_primary_common_state
      - salt: control_plane_primary_docker_state
      - salt: etcd_state