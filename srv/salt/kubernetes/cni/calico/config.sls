# -*- coding: utf-8 -*-
# vim: ft=jinja

/srv/kubernetes/charts/calico:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/calico:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True
