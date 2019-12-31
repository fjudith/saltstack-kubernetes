{%- from "kubernetes/map.jinja" import common with context -%}

base:
  '*':
    - common
  'role:proxy':
    - match: grain
    - haproxy
    - kubernetes.cri.docker
  'role:etcd':
    - match: grain
    - kubernetes.role.etcd
  'kubeadm_init':
    - match: nodegroup
    - kubernetes.cri.docker
    - kubernetes.role.master.kubeadm.init
  'kubeadm_join_master':
    - match: nodegroup
    - kubernetes.cri.docker
    - kubernetes.role.master.kubeadm.join
  'kubeadm_join_proxy':
    - match: nodegroup
    - kubernetes.cri.docker
    - kubernetes.role.proxy.kubeadm
  'kubeadm_join_node':
    - match: nodegroup
    - kubernetes.cri.docker
    - kubernetes.role.node.kubeadm
  'kubernetes_apps'
    - match: nodegroup
    - kubernetes.cni.{{ common.cni.provider }}
    - kubernetes.addons.metrics-server
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
