{%- from "kubernetes/map.jinja" import common with context -%}

base:
  '*':
  {# 'role:proxy':
    - match: grain
    - haproxy
    - common
    - kubernetes.cri.docker
  'role:etcd':
    - match: grain
    - common
    - kubernetes.cri.docker
  'master01'
    - match: hostname
    - common
    - kubernetes.cri.docker
    - kubernetes.role.master.kubeadm
  'role:master':
    - match: grain
    - common
    - kubernetes.cri.docker
  'role:node':
    - match: grain
    - common
    - kubernetes.cri.docker #}

  {% if "proxy" in grains.get('role', []) %}
    - haproxy
    - common
    - kubernetes.cri.docker
  {% endif %}
  {% if "etcd" in grains.get('role', []) %}
    - common
    - kubernetes.cri.docker
    - kubernetes.role.etcd
  {% endif %}
  {%- if 'master01' in grains.get('fqdn', [])|lower %}
    - common
    - kubernetes.cri.docker
    - kubernetes.role.master.kubeadm.init
    - kubernetes.cni.{{ common.cni.provider }}
  {% endif %}
  {% if "master" in grains.get('role', []) and not 'master01' in grains.get('fqdn', [])|lower %}
    - common
    - kubernetes.cri.docker
    - kubernetes.role.master.kubeadm.join
  {% endif %}
  {% if "proxy" in grains.get('role', []) %}
    - haproxy
    - common
    - kubernetes.cri.docker
    - kubernetes.role.master.kubeadm
  {% endif %}
  {% if "node" in grains.get('role', []) %}
    - common
    - kubernetes.cri.docker
  {% endif %}
  
  
