{%- set node_name = salt['pillar.get']('event_originator') -%}
{%- set etcds = [] -%}
{%- for key, value in salt["saltutil.runner"]('mine.get', tgt="role:etcd", fun="network.get_hostname", tgt_type="grain")|dictsort(false, 'value') -%}
  {%- do etcds.append(value) -%}
{%- endfor -%}

{% if etcds|length > 1 %}

{# etcd_etcdadm_join_etcd:
  salt.state:
    - tgt: "{{ etcds[1:]|join(",") }}"
    - tgt_type: "list"
    - sls: kubernetes.role.etcd.etcdadm
    - queue: True
    - batch: 1
    - require:
      - salt: common_state
      - salt: docker_state
      - salt: etcd_primary_etcdadm_init #}

etcd_join:
  salt.state:
    - tgt: "{{ etcds[1:]|join(",") }}"
    - tgt_type: "list"
    - sls: kubernetes.role.etcd
    - queue: True
    - batch: 1
    {# - require:
      - salt: common_state
      - salt: docker_state
      - salt: etcd_init #}
{% endif %}