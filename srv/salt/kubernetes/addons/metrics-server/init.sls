{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/metrics-server:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/metrics-server/aggregated-metrics-reader.yaml:
    require:
    - file: /srv/kubernetes/manifests/metrics-server
    file.managed:
    - source: salt://kubernetes/addons/metrics-server/files/aggregated-metrics-reader.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/metrics-server/auth-delegator.yaml:
    require:
    - file: /srv/kubernetes/manifests/metrics-server
    file.managed:
    - source: salt://kubernetes/addons/metrics-server/files/auth-delegator.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/metrics-server/auth-reader.yaml:
    require:
    - file: /srv/kubernetes/manifests/metrics-server
    file.managed:
    - source: salt://kubernetes/addons/metrics-server/files/auth-reader.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/metrics-server/metrics-apiservice.yaml:
    require:
    - file: /srv/kubernetes/manifests/metrics-server
    file.managed:
    - source: salt://kubernetes/addons/metrics-server/files/metrics-apiservice.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/metrics-server/metrics-server-service.yaml:
    require:
    - file: /srv/kubernetes/manifests/metrics-server
    file.managed:
    - source: salt://kubernetes/addons/metrics-server/files/metrics-server-service.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/metrics-server/resource-reader.yaml:
    require:
    - file: /srv/kubernetes/manifests/metrics-server
    file.managed:
    - source: salt://kubernetes/addons/metrics-server/files/resource-reader.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/metrics-server/metrics-server-deployment.yaml:
    require:
    - file: /srv/kubernetes/manifests/metrics-server
    file.managed:
    - source: salt://kubernetes/addons/metrics-server/templates/metrics-server-deployment.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644

metrics-server-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/metrics-server/aggregated-metrics-reader.yaml
      - file: /srv/kubernetes/manifests/metrics-server/auth-delegator.yaml
      - file: /srv/kubernetes/manifests/metrics-server/auth-reader.yaml
      - file: /srv/kubernetes/manifests/metrics-server/metrics-apiservice.yaml
      - file: /srv/kubernetes/manifests/metrics-server/metrics-server-deployment.yaml
      - file: /srv/kubernetes/manifests/metrics-server/metrics-server-service.yaml
      - file: /srv/kubernetes/manifests/metrics-server/resource-reader.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/metrics-server/