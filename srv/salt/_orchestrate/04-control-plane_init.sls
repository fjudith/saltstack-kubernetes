{%- set node_name = salt['pillar.get']('event_originator') -%}
{%- set masters = [] -%}
{%- for key, value in salt["saltutil.runner"]('mine.get', tgt="role:master", fun="network.get_hostname", tgt_type="grain")|dictsort(false, 'value') -%}
  {%- do masters.append(value) -%}
{%- endfor -%}

{% if masters|length < 1 %}
{{ raise('ERROR: at least one master must be specified') }}
{% endif %}

{% set cri_provider = salt['pillar.get']('kubernetes:common:cri:provider') %}
{% set cni_provider = salt['pillar.get']('kubernetes:common:cni:provider') %}

control-plane-cri-main:
  salt.state:
    - tgt: "{{ masters|first }}"
    - sls: kubernetes.cri.{{ cri_provider }}
    - queue: True

control-plane-kubeadm_init:
  salt.state:
    - tgt: "{{ masters|first }}"
    - sls: kubernetes.role.master.kubeadm
    - queue: True
    - require:
      - salt: control-plane-cri-main
      - salt: envoy
      - salt: etcd

cni:
  salt.state:
    - tgt: "{{ masters|first }}"
    - sls: kubernetes.cni.{{ cni_provider }}
    - queue: True
    - require:
      - salt: control-plane-kubeadm_init