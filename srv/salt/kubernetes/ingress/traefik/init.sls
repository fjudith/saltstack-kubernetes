{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/traefik:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/traefik/traefik.yaml:
    require:
    - file: /srv/kubernetes/manifests/traefik
    file.managed:
    - source: salt://kubernetes/ingress/traefik/templates/traefik.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"

/srv/kubernetes/manifests/traefik/service-monitor.yaml:
    require:
    - file: /srv/kubernetes/manifests/traefik
    file.managed:
    - source: salt://kubernetes/ingress/traefik/files/service-monitor.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"

/srv/kubernetes/manifests/traefik/grafana-dashboard.yaml:
    require:
    - file: /srv/kubernetes/manifests/traefik
    file.managed:
    - source: salt://kubernetes/ingress/traefik/files/grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: "0644"

kubernetes-traefik-install:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/traefik/traefik.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/traefik/traefik.yaml
        {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
        kubectl apply -f /srv/kubernetes/manifests/traefik/service-monitor.yaml
        kubectl apply -f /srv/kubernetes/manifests/traefik/grafana-dashboard-configmap.yaml
        {%- endif %}
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
