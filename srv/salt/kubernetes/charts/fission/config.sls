/srv/kubernetes/manifests/fission:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/fission/values.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/fission
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
