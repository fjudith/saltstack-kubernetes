{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import kubeadm with context -%}

include:
  - .config
  - .namespace
  {%- if kubeadm.get('etcd', {'external': False}).external %}
  - .external-etcd-cert.sls
  {%- endif %}
  - .install
  {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
  - .prometheus
  {%- endif %}
  - .storageclass