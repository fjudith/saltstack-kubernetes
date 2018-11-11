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
    - kubernetes.csi
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
