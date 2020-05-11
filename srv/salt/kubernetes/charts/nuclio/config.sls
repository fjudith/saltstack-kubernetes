/srv/kubernetes/manifests/nuclio:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/nuclio/values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/nuclio
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}