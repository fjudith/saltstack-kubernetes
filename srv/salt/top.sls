base:
  '*':
  {% if "etcd" in grains.get('role', []) %}
    - common
    - certs
    - kubernetes.role.etcd
  {% endif %}
  {% if "master" in grains.get('role', []) %}
    - common
    - certs
    - kubernetes.role.master
    {%- if pillar.kubernetes.master.storage.get('rook', {'enabled': False}).enabled %}
    - kubernetes.csi.rook
    {%- endif %}
    - kubernetes.addons
    - kubernetes.charts
  {% endif %}
  {% if "node" in grains.get('role', []) %}
    - common
    - certs
    - kubernetes.role.node
  {% endif %}
  {% if "proxy" in grains.get('role', []) %}
    - common
    - kubernetes.role.proxy
    - certs
    - kubernetes.role.node
  {% endif %}
