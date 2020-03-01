/srv/kubernetes/manifests/fluentd-elasticsearch:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/fluentd-elasticsearch/es-service.yaml:
  file.managed:
    - watch:
      - file: /srv/kubernetes/manifests/fluentd-elasticsearch
    - source: salt://{{ tpldir }}/files/es-service.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/fluentd-elasticsearch/fluentd-es-configmap.yaml:
  file.managed:
    - watch:
      - file: /srv/kubernetes/manifests/fluentd-elasticsearch
    - source: salt://{{ tpldir }}/files/fluentd-es-configmap.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/fluentd-elasticsearch/kibana-service.yaml:
  file.managed:
    - watch:
      - file: /srv/kubernetes/manifests/fluentd-elasticsearch
    - source: salt://{{ tpldir }}/files/kibana-service.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/fluentd-elasticsearch/fluentd-es-ds.yaml:
  file.managed:
    - watch:
      - file: /srv/kubernetes/manifests/fluentd-elasticsearch
    - source: salt://{{ tpldir }}/templates/fluentd-es-ds.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/fluentd-elasticsearch/kibana-deployment.yaml:
  file.managed:
    - watch:
      - file: /srv/kubernetes/manifests/fluentd-elasticsearch
    - source: salt://{{ tpldir }}/templates/kibana-deployment.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/fluentd-elasticsearch/es-statefulset.yaml:
  file.managed:
    - watch:
      - file: /srv/kubernetes/manifests/fluentd-elasticsearch
    - source: salt://{{ tpldir }}/templates/es-statefulset.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}
