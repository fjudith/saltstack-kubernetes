{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import storage with context -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

{% if storage.get('rook_ceph', {'enabled': False}).enabled %}
ceph-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/rook-ceph-grafana-dashboard-configmap.yaml
    - watch:
      - file: /srv/kubernetes/manifests/kube-prometheus
    - source: salt://{{ tpldir }}/files/rook-ceph-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - file: /srv/kubernetes/manifests/kube-prometheus/rook-ceph-grafana-dashboard-configmap.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/rook-ceph-grafana-dashboard-configmap.yaml
{% endif %}

{% if storage.get('portworx', {'enabled': False}).enabled %}
portworx-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/portworx-grafana-dashboard-configmap.yaml
    - watch:
      - file: /srv/kubernetes/manifests/kube-prometheus
    - source: salt://{{ tpldir }}/files/portworx-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - file: /srv/kubernetes/manifests/kube-prometheus/rook-ceph-grafana-dashboard-configmap.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/rook-ceph-grafana-dashboard-configmap.yaml
{% endif %}

{% if common.addons.get('nats_operator', {'enabled': False}).enabled %}
nats-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/nats-grafana-dashboard-configmap.yaml
    - watch:
      - file: /srv/kubernetes/manifests/kube-prometheus
    - source: salt://{{ tpldir }}/files/nats-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - file: /srv/kubernetes/manifests/kube-prometheus/nats-grafana-dashboard-configmap.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/nats-grafana-dashboard-configmap.yaml
{% endif %}

{% if common.addons.get('nginx', {'enabled': False}).enabled %}
nginx-ingress-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/nginx-ingress-grafana-dashboard-configmap.yaml
    - watch:
      - file: /srv/kubernetes/manifests/kube-prometheus
    - source: salt://{{ tpldir }}/files/nginx-ingress-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - file: /srv/kubernetes/manifests/kube-prometheus/nginx-ingress-grafana-dashboard-configmap.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/nginx-ingress-grafana-dashboard-configmap.yaml
{% endif %}

{% if common.addons.get('traefik', {'enabled': False}).enabled %}
traefik-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/traefik-grafana-dashboard-configmap.yaml
    - watch:
      - file: /srv/kubernetes/manifests/kube-prometheus
    - source: salt://{{ tpldir }}/files/traefik-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - file: /srv/kubernetes/manifests/kube-prometheus/traefik-grafana-dashboard-configmap.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/traefik-grafana-dashboard-configmap.yaml
{% endif %}

{% if common.addons.get('cert_manager', {'enabled': False}).enabled %}
traefik-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/cert-manager-grafana-dashboard-configmap.yaml
    - watch:
      - file: /srv/kubernetes/manifests/kube-prometheus
    - source: salt://{{ tpldir }}/files/cert-manager-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - file: /srv/kubernetes/manifests/kube-prometheus/cert-manager-grafana-dashboard-configmap.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/cert-manager-grafana-dashboard-configmap.yaml
{% endif %}

{% if charts.get('openfaas', {'enabled': False}).enabled %}
openfaas-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/openfaas-grafana-dashboard-configmap.yaml
    - watch:
      - file: /srv/kubernetes/manifests/kube-prometheus
    - source: salt://{{ tpldir }}/files/openfaas-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - file: /srv/kubernetes/manifests/kube-prometheus/openfaas-grafana-dashboard-configmap.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/openfaas-grafana-dashboard-configmap.yaml
{% endif %}

{% if charts.get('falco', {'enabled': False}).enabled %}
falco-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/falco-grafana-dashboard-configmap.yaml
    - watch:
      - file: /srv/kubernetes/manifests/kube-prometheus
    - source: salt://{{ tpldir }}/files/falco-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - file: /srv/kubernetes/manifests/kube-prometheus/falco-grafana-dashboard-configmap.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/falco-grafana-dashboard-configmap.yaml
{% endif %}

{% if common.addons.get('rook_cockroachdb', {'enabled': False}).enabled %}
cockroachdb-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/cockroachdb-grafana-dashboard-configmap.yaml
    - watch:
      - file: /srv/kubernetes/manifests/kube-prometheus
    - source: salt://{{ tpldir }}/files/cockroachdb-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - file: /srv/kubernetes/manifests/kube-prometheus/cockroachdb-grafana-dashboard-configmap.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/cockroachdb-grafana-dashboard-configmap.yaml
{% endif %}
