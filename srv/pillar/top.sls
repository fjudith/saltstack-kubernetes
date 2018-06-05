base:
  '*':
  {% if "etcd" in grains.get('role', []) or "master" or "node" in grains.get('role', []) %}
    - cluster_config
  {% endif %}
