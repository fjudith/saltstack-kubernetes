/srv/kubernetes/manifests/harbor:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/harbor/values.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
