/srv/kubernetes/manifests/metrics-server:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

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