{%- from "kubernetes/map.jinja" import common with context -%}

base:
  '*':
  {% if "etcd" in grains.get('role', []) %}
    - common
    - certs
    - kubernetes.cri.docker
    - kubernetes.role.etcd
  {% endif %}
  {% if "master" in grains.get('role', []) %}
    - common
    - certs
    - kubernetes.role.master
    - kubernetes.cni
    - kubernetes.cri
    - kubernetes.cri.{{ common.cri.provider }}
    - kubernetes.role.master.kubelet
    - kubernetes.role.master.kube-proxy
    - kubernetes.role.master.kube-apiserver
    - kubernetes.role.master.kube-controller-manager
    - kubernetes.role.master.kube-scheduler
    - kubernetes.cni.{{ common.cni.provider }}
    {%- if common.addons.dns.get('coredns', {'enabled': False}).enabled %}
    - kubernetes.addons.coredns
    {%- endif %}
    {%- if common.addons.get('helm', {'enabled': False}).enabled %}
    - kubernetes.addons.helm
    {%- endif %}
    - kubernetes.ingress
    {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
    - kubernetes.addons.kube-prometheus
    {%- endif %}
    - kubernetes.csi
    - kubernetes.addons
    - kubernetes.charts
  {% endif %}
  {% if "node" in grains.get('role', []) %}
    - common
    - certs
    - kubernetes.role.node
    - kubernetes.cni
    - kubernetes.cri
    - kubernetes.cri.{{ common.cri.provider }}
    - kubernetes.role.node.kubelet
    - kubernetes.role.node.kube-proxy
  {% endif %}
  {% if "proxy" in grains.get('role', []) %}
    - common
    - certs
    - kubernetes.role.proxy
    - tinyproxy
    - keepalived
    - haproxy
    - kubernetes.role.node
    - kubernetes.cni
    - kubernetes.cri
    - kubernetes.cri.{{ common.cri.provider }}
    - kubernetes.role.proxy.kubelet
    - kubernetes.role.proxy.kube-proxy
  {% endif %}
