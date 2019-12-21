/srv/kubernetes/manifests/harbor:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/harbor/values.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - source: salt://kubernetes/charts/harbor/templates/values.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
