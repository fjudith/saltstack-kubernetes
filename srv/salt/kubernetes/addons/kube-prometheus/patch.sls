{%- from "kubernetes/map.jinja" import common with context -%}

{% if common.addons.get('rook_ceph', {'enabled': False}).enabled %}
ceph-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/manifests/ceph-grafana-dashboard-configmap.yaml
    - watch:
      - git: kube-prometheus-repo
    - source: salt://{{ tpldir }}/patch/ceph-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: kube-prometheus
        - file: /srv/kubernetes/manifests/kube-prometheus/manifests/ceph-grafana-dashboard-configmap.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/manifests/ceph-grafana-dashboard-configmap.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
{% endif %}

{% if common.addons.get('nats_operator', {'enabled': False}).enabled %}
nats-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/manifests/nats-grafana-dashboard-configmap.yaml
    - watch:
      - git: kube-prometheus-repo
    - source: salt://{{ tpldir }}/patch/nats-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: kube-prometheus
        - file: /srv/kubernetes/manifests/kube-prometheus/manifests/nats-grafana-dashboard-configmap.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/manifests/nats-grafana-dashboard-configmap.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
{% endif %}

{% if common.addons.get('nginx', {'enabled': False}).enabled %}
nginx-ingress-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/manifests/nginx-ingress-grafana-dashboard-configmap.yaml
    - watch:
      - git: kube-prometheus-repo
    - source: salt://{{ tpldir }}/patch/nginx-ingress-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: kube-prometheus
        - file: /srv/kubernetes/manifests/kube-prometheus/manifests/nginx-ingress-grafana-dashboard-configmap.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/manifests/nginx-ingress-grafana-dashboard-configmap.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
{% endif %}

{% if common.addons.get('traefik', {'enabled': False}).enabled %}
traefik-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/manifests/traefik-grafana-dashboard-configmap.yaml
    - watch:
      - git: kube-prometheus-repo
    - source: salt://{{ tpldir }}/patch/traefik-grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: kube-prometheus
        - file: /srv/kubernetes/manifests/kube-prometheus/manifests/traefik-grafana-dashboard-configmap.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/manifests/traefik-grafana-dashboard-configmap.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
{% endif %}

kube-prometheus-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/manifests/grafana-deployment.yaml
    - watch:
      - git: kube-prometheus-repo
    - source: salt://{{ tpldir }}/patch/grafana-deployment.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: kube-prometheus
        - file: /srv/kubernetes/manifests/kube-prometheus/manifests/grafana-deployment.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/manifests/grafana-deployment.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'