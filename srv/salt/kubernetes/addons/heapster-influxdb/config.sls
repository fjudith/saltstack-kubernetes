/srv/kubernetes/manifests/heapster-influxdb:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/heapster-influxdb/heapster-controller.yaml:
  file.managed:
    - require:
        - file: /srv/kubernetes/manifests/heapster-influxdb
    - source: salt://{{ tpldir }}/templates/heapster-controller.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/heapster-influxdb/influxdb-grafana.yaml:
  file.managed:
    - require:
        - file: /srv/kubernetes/manifests/heapster-influxdb
    - source: salt://{{ tpldir }}/templates/influxdb-grafana.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/heapster-influxdb/heapster-rbac.yaml:
  file.managed:
    - require:
        - file: /srv/kubernetes/manifests/heapster-influxdb
    - source: salt://{{ tpldir }}/files/heapster-rbac.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/heapster-influxdb/heapster-service.yaml:
  file.managed:
    - require:
        - file: /srv/kubernetes/manifests/heapster-influxdb
    - source: salt://{{ tpldir }}/files/heapster-service.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/heapster-influxdb/influxdb-service.yaml:
  file.managed:
    - require:
        - file: /srv/kubernetes/manifests/heapster-influxdb
    - source: salt://{{ tpldir }}/files/influxdb-service.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/heapster-influxdb/grafana-service.yaml:
  file.managed:
    - require:
        - file: /srv/kubernetes/manifests/heapster-influxdb
    - source: salt://{{ tpldir }}/files/grafana-service.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}