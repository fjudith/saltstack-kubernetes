{%- from "kubernetes/map.jinja" import common with context -%}

include:
  - kubernetes.cri.docker.repo
  - kubernetes.cri.docker.install
  - kubernetes.cri.docker.config