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
    - require:
      - cmd: kubernetes-wait
    - watch:
      - file: /srv/kubernetes/manifests/fluentd-elasticsearch
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/fluentd-elasticsearch/