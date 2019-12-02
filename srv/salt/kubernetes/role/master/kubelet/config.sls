/var/lib/kubelet:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/var/lib/kubelet/kubelet-config.yaml:
  file.managed:
    - require:
      - file: /var/lib/kubelet
    - source: salt://kubernetes/role/master/kubelet/templates/kubelet-config.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644