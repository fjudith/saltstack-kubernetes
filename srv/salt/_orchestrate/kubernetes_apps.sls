{%- from "kubernetes/map.jinja" import common with context -%}
{%- set node_name = salt['pillar.get']('event_originator') -%}

cni_state:
  salt.state:
    - tgt: 'master01'
    - sls: kubernetes.cni.{{ common.cni.provider }}
    - queue: True

metrics-server_state:
  salt.state:
    - tgt: 'master01'
    - sls: kubernetes.addons.metrics-server
    - queue: True
    - require:
      - state: cni_state

{% if common.addons.dns.get('coredns', {'enabled': False}).enabled %}
coredns_state:
  salt.state:
    - tgt: 'master01'
    - sls: kubernetes.addons.coredns
    - queue: True
    - require:
      - state: cni_state
{% endif %}

{% if common.addons.get('helm', {'enabled': False}).enabled %}
helm_state:
  salt.state:
    - tgt: 'master01'
    - sls: kubernetes.addons.helm
    - queue: True
    - require:
      - state: cni_state
      - state: metrics-server_state
{% endif %}

kube-prometheus_state:
  salt.state:
    - tgt: 'master01'
    - sls: kubernetes.addons.kube-prometheus
    - queue: True
    - require:
      - state: cni_state
      - state: metrics-server_state

ingress_state:
  salt.state:
    - tgt: 'master01'
    - sls: kubernetes.ingress
    - queue: True
    - require:
      - state: cni_state
      - state: metrics-server_state
      - state: kube-prometheus_state

csi_state:
  salt.state:
    - tgt: 'master01'
    - sls: kubernetes.csi
    - queue: True
    - require:
      - state: cni_state
      - state: metrics-server_state
      - state: kube-prometheus_state


addons_state:
  salt.state:
    - tgt: 'master01'
    - sls: kubernetes.addons
    - queue: True
    - require:
      - state: cni_state
      - state: metrics-server_state
      - state: kube-prometheus_state
      - state: csi_state

{% if common.addons.get('helm', {'enabled': False}).enabled %}
charts_state:
  salt.state:
    - tgt: 'master01'
    - sls: kubernetes.charts
    - queue: True
    - require:
      - state: cni_state
      - state: metrics-server_state
      - state: kube-prometheus_state
      - state: csi_state
{% endif %}
    