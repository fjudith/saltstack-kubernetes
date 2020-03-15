/srv/kubernetes/manifests/node-problem-detector:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/node-problem-detector/node-problem-detector-config.yaml:
  file.managed:
    - require:
        - file: /srv/kubernetes/manifests/node-problem-detector
    - source: salt://{{ tpldir }}/files/node-problem-detector-config.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/node-problem-detector/node-problem-detector.yaml:
  file.managed:
    - require:
        - file: /srv/kubernetes/manifests/node-problem-detector
    - source: salt://{{ tpldir }}/templates/node-problem-detector.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}
