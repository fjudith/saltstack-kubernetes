{%- set node_name = salt['pillar.get']('event_originator') -%}
{%- set masters = [] -%}
{%- for key, value in salt["saltutil.runner"]('mine.get', tgt="role:master", fun="network.get_hostname", tgt_type="grain")|dictsort(false, 'value') -%}
  {%- do masters.append(value) -%}
{%- endfor -%}

{% if masters|length > 1 %}
control_plane_common_state:
  salt.state:
    - tgt: "{{ master[:1] }}"
    - sls: common

control_plane_docker_state_{{ master }}:
  salt.state:
    - tgt: "{{ master[:1] }}"
    - sls: kubernetes.cri.docker

{%- for master in masters[1:] %}
control_plane_kubeadm_join_{{ master }}:
  salt.state:
    - tgt: "{{ master }}"
    - sls: kubernetes.role.master.kubeadm
    - require:
      - salt: control_plane_common_state
      - salt: control_plane_docker_state
{%- endfor %}
{% endif %}