base:
  '*':
  {% if "master" in grains.get('role', []) %}
    {# - common #}
    - certs
    - kubernetes.master
    - kubernetes.addons
  {% endif %}
  {% if "node" in grains.get('role', []) %}
    {# - common #}
    - certs
    - kubernetes.node
  {% endif %}
  {% if "etcd" in grains.get('role', []) %}
    {# - common #}
    - certs
    - kubernetes.etcd
  {% endif %}
  {% if "proxy" in grains.get('role', []) %}
    {# - common #}
    - kubernetes.proxy
    - certs
    - kubernetes.node
  {% endif %}
