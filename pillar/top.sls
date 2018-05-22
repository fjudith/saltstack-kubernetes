base:
  '*':
  {% if "master" in grains.get('role', []) or "node" in grains.get('role', []) %}
    - cluster_config
  {% endif %}
