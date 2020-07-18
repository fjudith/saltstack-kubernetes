{%- set etcds = [] -%}
{%- for key, value in salt["mine.get"](tgt="role:etcd", fun="network.get_hostname", tgt_type="grain")|dictsort(false, 'value') -%}
  {%- do etcds.append(value) -%}
{%- endfor -%}

include:
  - .config
  - .install
  {%- if grains['id'] == etcds|first %}
  - .etcdadm-init
  {% else %}
  - .etcdadm-join
  {%- endif %}
  - .patch