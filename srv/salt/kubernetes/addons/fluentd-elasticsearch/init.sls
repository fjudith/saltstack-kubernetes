{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/fluentd-elasticsearch:
    file.recurse:
    - source: salt://kubernetes/addons/fluentd-elasticsearch/files
    - include_empty: True
    - user: root
    - group: root
    - file_mode: 644

/srv/kubernetes/manifests/fluentd-elasticsearch/es-statefulset.yaml:
    file.managed:
    - watch:
      - file: /srv/kubernetes/manifests/fluentd-elasticsearch
    - source: salt://kubernetes/addons/fluentd-elasticsearch/templates/es-statefulset.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/fluentd-elasticsearch/fluentd-es-configmap.yaml:
    file.managed:
    - watch:
      - file: /srv/kubernetes/manifests/fluentd-elasticsearch
    - source: salt://kubernetes/addons/fluentd-elasticsearch/templates/fluentd-es-configmap.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-fluentd-elasticsearch-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/fluentd-elasticsearch
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/fluentd-elasticsearch/
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
