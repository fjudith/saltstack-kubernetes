base:
  '*':
  {% if "master" in grains.get('role', []) %}
    {# - common #}
    - certs
    - kubernetes.master
    - kubernetes.addons
    {%- if pillar.kubernetes.master.storage.get('rook', {'enabled': False}).enabled %}
    - kubernetes.csi.rook
    {%- endif -%}
  {% endif %}
  {% if "node" in grains.get('role', []) %}
    {# - common #}
    - certs
    - kubernetes.node
  {% endif %}
  {% if "etcd" in grains.get('role', []) %}
    {# - common #}
    - certs
    - kubernetes.etcd
  {% endif %}
  {% if "proxy" in grains.get('role', []) %}
    {# - common #}
    - kubernetes.proxy
    - certs
    - kubernetes.node
  {% endif %}
