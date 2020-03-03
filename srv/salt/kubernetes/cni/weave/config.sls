/srv/kubernetes/manifests/weave:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/weave/weave.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/weave
    - source: salt://{{ tpldir }}/templates/weave.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}