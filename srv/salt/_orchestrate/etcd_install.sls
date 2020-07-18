{%- set node_name = salt['pillar.get']('event_originator') -%}
{%- set etcds = [] -%}
{%- for key, value in salt["saltutil.runner"]('mine.get', tgt="role:etcd", fun="network.get_hostname", tgt_type="grain")|dictsort(false, 'value') -%}
  {%- do etcds.append(value) -%}
{%- endfor -%}

{% if etcds|length < 1 %}
{{ raise('ERROR: at least one etcd must be specified') }}
{% endif %}

etcd_ca_state:
  salt.state:
    - tgt: '{{ etcds|first }}'
    - tgt_type: list
    - sls: kubernetes.role.etcd.ca
    - queue: True

etcd_state:
  salt.state:
    - tgt: '{{ etcds|join(",") }}'
    - tgt_type: list
    - sls: kubernetes.role.etcd
    - queue: True
    - require:
      - salt: etcd_ca_state
      - salt: common_state
      - salt: docker_state