/srv/kubernetes/manifests/spinnaker:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/spinnaker/values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/spinnaker
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
      tpldir: {{ tpldir }}