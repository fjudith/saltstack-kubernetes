{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/traefik:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/traefik/monitoring/kube-prometheus:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/traefik/traefik.yaml:
    require:
    - file: /srv/kubernetes/manifests/traefik
    file.managed:
    - source: salt://kubernetes/addons/traefik/traefik.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/traefik/monitoring/kube-prometheus/service-monitor.yaml:
    require:
    - file: /srv/kubernetes/manifests/traefik/monitoring/kube-prometheus
    file.managed:
    - source: salt://kubernetes/addons/traefik/monitoring/kube-prometheus/service-monitor.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/traefik/monitoring/kube-prometheus/grafana-dashboard.yaml:
    require:
    - file: /srv/kubernetes/manifests/traefik/monitoring/kube-prometheus
    file.managed:
    - source: salt://kubernetes/addons/traefik/monitoring/kube-prometheus/grafana-dashboard.yaml
    - user: root
    - group: root
    - mode: 644

kubernetes-traefik-install:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/traefik/traefik.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/traefik/traefik.yaml
        {%- if common.addons.get('kube-prometheus', {'enabled': False}).enabled %}
        kubectl apply -f /srv/kubernetes/manifests/traefik/monitoring/kube-prometheus/service-monitor.yaml
        kubectl apply -f /srv/kubernetes/manifests/traefik/monitoring/kube-prometheus/grafana-dashboard.yaml
        {%- endif %}
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
