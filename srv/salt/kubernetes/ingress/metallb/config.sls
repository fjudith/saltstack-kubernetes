/srv/kubernetes/manifests/metallb:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/metallb/values.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/metallb
    - source: salt://kubernetes/ingress/metallb/templates/values.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"