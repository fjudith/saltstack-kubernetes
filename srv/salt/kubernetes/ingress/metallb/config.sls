# -*- coding: utf-8 -*-
# vim: ft=jinja

/srv/kubernetes/charts/metallb:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/metallb:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True
