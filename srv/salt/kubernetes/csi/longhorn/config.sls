/srv/kubernetes/manifests/longhorn:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/longhorn/longhorn.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/longhorn
    - source: salt://{{ tpldir }}/templates/longhorn.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}