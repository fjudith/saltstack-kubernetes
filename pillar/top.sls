base:
  '*':
  {% if "master" in grains.get('role', []) or "worker" in grains.get('role', []) %}
    - cluster_config
  {% endif %}
