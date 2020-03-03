/srv/kubernetes/manifests/flannel:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/flannel/flannel.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/flannel
    - source: salt://{{ tpldir }}/templates/flannel.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}