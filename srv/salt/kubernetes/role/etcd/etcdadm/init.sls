{%- set etcd = [] -%}
{%- for key, value in salt["mine.get"](tgt="role:etcd", fun="network.get_hostname", tgt_type="grain")|dictsort(false, 'value') -%}
  {%- do etcd.append(value) -%}
{%- endfor -%}

include:
  - install
  {%- if grains['id'] == etcd|first %}
  - .kubeadm-init
  {% else %}
  - .kubeadm-join
  {%- endif %}