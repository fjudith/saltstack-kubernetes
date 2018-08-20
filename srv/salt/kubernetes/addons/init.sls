{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}

kubernetes-wait:
  cmd.run:
    - runas: root
    - name: until curl --silent 'http://127.0.0.1:8080/version/'; do printf 'Kubernetes API and extension not ready' && sleep 5; done
    - use_vt: True
    - timeout: 300

/srv/kubernetes/manifests:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

include:
  - kubernetes.addons.default-cluster-role-binding
{%- if common.addons.dns.get('coredns', {'enabled': False}).enabled %}
  - kubernetes.addons.coredns
{%- endif -%}
{%- if common.addons.dns.get('autoscaler', {'enabled': False}).enabled %}
  - kubernetes.addons.dns-horizontal-autoscaler
{%- endif -%}
{%- if common.addons.get('dashboard', {'enabled': False}).enabled %}
  - kubernetes.addons.kube-dashboard
{%- endif -%}
{%- if common.addons.get('npd', {'enabled': False}).enabled %}
  - kubernetes.addons.node-problem-detector
{%- endif -%}
{%- if common.addons.get('heapster-influxdb', {'enabled': False}).enabled %}
  - kubernetes.addons.influxdb-grafana
{%- endif -%}
{%- if common.addons.get('fluentd-elasticsearch', {'enabled': False}).enabled %}
  - kubernetes.addons.fluentd-elasticsearch
{%- endif -%}
{%- if common.addons.get('cert_manager', {'enabled': False}).enabled %}
  - kubernetes.addons.cert-manager
{%- endif -%}
{%- if common.addons.get('ingress_nginx', {'enabled': False}).enabled %}
  - kubernetes.addons.ingress-nginx
{%- endif -%}
{%- if common.addons.get('ingress_traefik', {'enabled': False}).enabled %}
  - kubernetes.addons.traefik
{%- endif -%}
{%- if common.addons.get('ingress_istio', {'enabled': False}).enabled %}
  - kubernetes.addons.istio
{%- endif -%}
{%- if common.addons.get('kube-prometheus', {'enabled': False}).enabled %}
  - kubernetes.addons.prometheus-operator
{%- endif -%}
{%- if common.addons.get('helm', {'enabled': False}).enabled %}
  - kubernetes.addons.helm
{%- endif -%}
{%- if common.addons.get('weave-scope', {'enabled': False}).enabled %}
  - kubernetes.addons.weave-scope
{%- endif -%}