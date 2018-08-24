{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/heapster.yaml:
    file.managed:
    - source: salt://kubernetes/addons/influxdb-grafana/heapster.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/heapster-rbac.yaml:
    file.managed:
    - source: salt://kubernetes/addons/influxdb-grafana/heapster-rbac.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/heapster-service.yaml:
    file.managed:
    - source: salt://kubernetes/addons/influxdb-grafana/heapster-service.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/influxdb-grafana.yaml:
    file.managed:
    - source: salt://kubernetes/addons/influxdb-grafana/influxdb-grafana.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-heapster-influxdb-install:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/heapster.yaml
      - /srv/kubernetes/manifests/heapster-rbac.yaml
      - /srv/kubernetes/manifests/heapster-service.yaml
      - /srv/kubernetes/manifests/influxdb-grafana.yaml
    - unless: curl --silent 'http://127.0.0.1:8080/version/'
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/heapster.yaml
        kubectl apply -f /srv/kubernetes/manifests/heapster-rbac.yaml
        kubectl apply -f /srv/kubernetes/manifests/heapster-service.yaml
        kubectl apply -f /srv/kubernetes/manifests/influxdb-grafana.yaml