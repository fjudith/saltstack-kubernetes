# -*- coding: utf-8 -*-
# vim: ft=jinja

/srv/kubernetes/charts/cilium:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/cilium:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True
