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
