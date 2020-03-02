# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{%- from tpldir ~ "/map.jinja" import crio with context %}

cri-o-runc:
  pkg.latest:
    - require:
      - pkgrepo: projectatomic-repo  
    - refresh: true
    - install_recommends: False

skopeo:
  pkg.latest:
    - require:
      - pkgrepo: projectatomic-repo  
    - refresh: true
    - install_recommends: False

skopeo-containers:
  pkg.latest:
    - require:
      - pkgrepo: projectatomic-repo  
    - refresh: true
    - install_recommends: False

cri-o-{{ crio.version }}:
  pkg.latest:
    - require:
      - pkgrepo: projectatomic-repo
    - refresh: true
    - install_recommends: False

/etc/cni/net.d/100-crio-bridge.conf:
  file.absent:
    - watch:
      - pkg: cri-o-{{ crio.version }}

ostree:
  pkg.latest:
    - require:
      - pkg: flatpak-repo
    - refresh: true