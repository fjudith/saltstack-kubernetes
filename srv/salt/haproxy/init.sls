# haproxy
#
# Meta-state to fully setup haproxy on debian. (or any other distro that has haproxy in their repo)

include:
{%- set haproxy_items = salt['pillar.get']('haproxy:include', []) %}
{%- for item in haproxy_items %}
  - {{ item }}
{%- endfor %}
  - haproxy.install
  - haproxy.service
  - haproxy.config