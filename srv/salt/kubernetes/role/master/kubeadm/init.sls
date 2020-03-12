{%- set masters = [] -%}
{%- for key, value in salt["mine.get"](tgt="role:master", fun="network.get_hostname", tgt_type="grain")|dictsort(false, 'value') -%}
  {%- do masters.append(value) -%}
{%- endfor -%}

include:
  - .osprep
  - .repo
  - .install
  - .audit-policy
  - .encryption
  {%- if grains['id'] == masters|first %}
  - .kubeadm-init
  {% else %}
  - .kubeadm-join
  {%- endif %}