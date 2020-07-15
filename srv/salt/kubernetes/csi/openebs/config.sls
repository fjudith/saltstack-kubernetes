/srv/kubernetes/manifests/openebs:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/openebs/openebs-operator.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/openebs
    - source: salt://{{ tpldir }}/templates/openebs-operator.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}