base:
  '*':
  {% if "master" in grains.get('role', []) %}
    - certs
    - master
  {% endif %}
  {% if "worker" in grains.get('role', []) %}
    - certs
    - worker
  {% endif %}
