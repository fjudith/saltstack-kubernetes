/srv/kubernetes/manifests/contour:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/contour/values.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/contour
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}