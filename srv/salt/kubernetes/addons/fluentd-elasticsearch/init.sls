{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/fluentd-elasticsearch:
    file.recurse:
    - source: salt://kubernetes/addons/fluentd-elasticsearch
    - include_empty: True
    - user: root
    - template: jinja
    - group: root
    - file_mode: 644

kubernetes-fluentd-elasticsearch-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/fluentd-elasticsearch
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/fluentd-elasticsearch/
    - unless: curl --silent 'http://127.0.0.1:8080/version/'
