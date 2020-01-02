/srv/kubernetes/manifests/metallb:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/metallb/values.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/metallb
    - source: salt://kubernetes/ingress/metallb/files/values.yaml
    - user: root
    - group: root
    - mode: 644