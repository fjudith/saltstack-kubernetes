{%- from "kubernetes/map.jinja" import storage with context -%}

include:
  - .driver
  - .config
  - .namespace
  - .install
  # - .blockdevice
  - .cstor
  - .jiva
  - .cstor-storageclass
  # - .ingress
  

