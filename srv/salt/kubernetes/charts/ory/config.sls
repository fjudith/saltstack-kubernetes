/srv/kubernetes/manifests/ory:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/ory/hydra-values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/ory
    - source: salt://{{ tpldir }}/templates/hydra-values.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}