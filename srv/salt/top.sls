base:
  '*':
  {% if "master" in grains.get('role', []) %}
    {# - common #}
    - certs
    - master
    - kubernetes
  {% endif %}
  {% if "node" in grains.get('role', []) %}
    {# - common #}
    - certs
    - node
  {% endif %}
  {% if "etcd" in grains.get('role', []) %}
    {# - common #}
    - certs
    - etcd
  {% endif %}
  {% if "proxy" in grains.get('role', []) %}
    {# - common #}
    - proxy
    - certs
    - node
  {% endif %}
