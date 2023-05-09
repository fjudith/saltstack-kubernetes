{%- from "kubernetes/map.jinja" import common with context -%}
{%- set node_name = salt['pillar.get']('event_originator') -%}
{%- set masters = [] -%}
{%- for key, value in salt["saltutil.runner"]('mine.get', tgt="role:master", fun="network.get_hostname", tgt_type="grain")|dictsort(false, 'value') -%}
  {%- do masters.append(value) -%}
{%- endfor -%}

metrics-server:
  salt.state:
    - tgt: "{{ masters|first }}"
    - sls: kubernetes.charts.metrics-server
    - queue: True
    

# {% if common.addons.dns.get('coredns', {'enabled': False}).enabled %}
# coredns_state:
#   salt.state:
#     - tgt: "{{ masters|first }}"
#     - sls: kubernetes.charts.coredns
#     - queue: True
#     - require:
#       - salt: cni_state
# {% endif %}

kube-prometheus:
  salt.state:
    - tgt: "{{ masters|first }}"
    - sls: kubernetes.charts.kube-prometheus
    - queue: True
    - require_in:
      - salt: ingress

ingress:
  salt.state:
    - tgt: "{{ masters|first }}"
    - sls: kubernetes.ingress
    - queue: True

# csi_state:
#   salt.state:
#     - tgt: "{{ masters|first }}"
#     - sls: kubernetes.csi
#     - queue: True
#     - require:
#       - salt: compute_kubeadm_join_node
#       - salt: cni_state
#       - salt: metrics-server_state
#       - salt: kube-prometheus_state
#       - salt: loopback_iscsi_state

# addons_state:
#   salt.state:
#     - tgt: "{{ masters|first }}"
#     - sls: kubernetes.addons
#     - queue: True
#     - require:
#       - salt: compute_kubeadm_join_node
#       - salt: edge_kubeadm_join_edge
#       - salt: cni_state
#       - salt: metrics-server_state
#       - salt: kube-prometheus_state
#       - salt: csi_state

# {% if common.addons.get('helm', {'enabled': False}).enabled %}
# charts_state:
#   salt.state:
#     - tgt: "{{ masters|first }}"
#     - sls: kubernetes.charts
#     - queue: True
#     - require:
#       - salt: compute_kubeadm_join_node
#       - salt: edge_kubeadm_join_edge
#       - salt: cni_state
#       - salt: metrics-server_state
#       - salt: kube-prometheus_state
#       - salt: csi_state
# {% endif %}
