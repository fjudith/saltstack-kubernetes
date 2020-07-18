{%- set node_name = salt['pillar.get']('event_originator') -%}
{%- set etcds = [] -%}
{%- for key, value in salt["saltutil.runner"]('mine.get', tgt="role:etcd", fun="network.get_hostname", tgt_type="grain")|dictsort(false, 'value') -%}
  {%- do etcds.append(value) -%}
{%- endfor -%}

{% if etcds|length < 1 %}
{{ raise('ERROR: at least one etcd must be specified') }}
{% endif %}

{# etcd_primary_etcdadm_init:
  salt.state:
    - tgt: "{{ etcds|first }}"
    - sls: kubernetes.role.etcd.etcdadm
    - queue: True
    - require:
      - salt: common_state
      - salt: docker_state #}

{# etcd_init:
  salt.state:
    - tgt: "{{ etcds|first }}"
    - sls: kubernetes.role.etcd
    - queue: True
    - require:
      - salt: common_state
      - salt: docker_state #}

etcd_ca:
  salt.state:
    - tgt: '{{ etcds|first }}'
    - tgt_type: list
    - sls: kubernetes.role.etcd.ca
    - queue: True

etcd_install:
  salt.state:
    - tgt: '{{ etcds|join(",") }}'
    - tgt_type: list
    - sls: kubernetes.role.etcd
    - queue: True
    - require:
      - salt: etcd_ca
      {# - salt: common_state
      - salt: docker_state
      - salt: etcd_init #}