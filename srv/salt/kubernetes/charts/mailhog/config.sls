/srv/kubernetes/manifests/mailhog:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True