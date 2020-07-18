{%- set etcds = [] -%}
{%- for key, value in salt["mine.get"](tgt="role:etcd", fun="network.get_hostname", tgt_type="grain")|dictsort(false, 'value') -%}
  {%- do etcds.append(value) -%}
{%- endfor -%}

include:
  - .config
  {%- if grains['id'] == etcds|first %}
  - .ca
  {%- else %}
  - .cert
  {%- endif %}
  - .install
  - .test