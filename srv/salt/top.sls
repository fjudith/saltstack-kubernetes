base:
  '*':
  {% if "etcd" in grains.get('role', []) %}
    - common
    - certs
    - kubernetes.etcd
  {% endif %}
  {% if "master" in grains.get('role', []) %}
    - common
    - certs
    - kubernetes.master
    {%- if pillar.kubernetes.master.storage.get('rook', {'enabled': False}).enabled %}
    - kubernetes.csi.rook
    {%- endif %}
    - kubernetes.addons
  {% endif %}
  {% if "node" in grains.get('role', []) %}
    - common
    - certs
    - kubernetes.node
  {% endif %}
  {% if "proxy" in grains.get('role', []) %}
    - common
    - kubernetes.proxy
    - certs
    - kubernetes.node
  {% endif %}
