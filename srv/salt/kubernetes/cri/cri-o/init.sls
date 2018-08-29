{%- from "kubernetes/map.jinja" import common with context -%}

cri-o:
  pkgrepo.managed:
    - humanname: Cri-O PPA
    - name: https://launchpad.net/~projectatomic/+archive/ubuntu/ppa 
    - file: /etc/apt/sources.list.d/cri-o.list
    - require_in
      - pkg: cri-o
  pkg.installed:
    - name: cri-o
    - install_recommends: False