base:
  '*':
  {% if "master" in grains.get('role', []) %}
    - certs
    - master
  {% endif %}
  {% if "node" in grains.get('role', []) %}
    - certs
    - node
  {% endif %}
  {% if "etcd" in grains.get('role', []) %}
    - certs
    - etcd
  {% endif %}
