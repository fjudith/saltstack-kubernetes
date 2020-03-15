/srv/kubernetes/manifests/metrics-server:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/metrics-server/aggregated-metrics-reader.yaml:
    require:
    - file: /srv/kubernetes/manifests/metrics-server
    file.managed:
    - source: salt://{{ tpldir }}/files/aggregated-metrics-reader.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/metrics-server/auth-delegator.yaml:
    require:
    - file: /srv/kubernetes/manifests/metrics-server
    file.managed:
    - source: salt://{{ tpldir }}/files/auth-delegator.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/metrics-server/auth-reader.yaml:
    require:
    - file: /srv/kubernetes/manifests/metrics-server
    file.managed:
    - source: salt://{{ tpldir }}/files/auth-reader.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/metrics-server/metrics-apiservice.yaml:
    require:
    - file: /srv/kubernetes/manifests/metrics-server
    file.managed:
    - source: salt://{{ tpldir }}/files/metrics-apiservice.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/metrics-server/metrics-server-service.yaml:
    require:
    - file: /srv/kubernetes/manifests/metrics-server
    file.managed:
    - source: salt://{{ tpldir }}/files/metrics-server-service.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/metrics-server/resource-reader.yaml:
    require:
    - file: /srv/kubernetes/manifests/metrics-server
    file.managed:
    - source: salt://{{ tpldir }}/files/resource-reader.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/metrics-server/metrics-server-deployment.yaml:
    require:
    - file: /srv/kubernetes/manifests/metrics-server
    file.managed:
    - source: salt://{{ tpldir }}/templates/metrics-server-deployment.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}