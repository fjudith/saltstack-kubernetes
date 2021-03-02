{%- from "kubernetes/map.jinja" import charts with context -%}

common_packages:
  pkg.latest:
    - pkgs:
      - azure-cli
      - ceph-common
      - httpie
      - jq
      - python3-m2crypto
      - linux-image-{{ grains['kernelrelease'] }}
      - linux-headers-{{ grains['kernelrelease'] }}
      - bpfcc-tools
    - refresh: true
    - reload_modules: true

{%- if charts.get('falco', {'enabled': False}).enabled %}
falco-packages:
  pkg.latest:
    - pkgs:
      - build-essential
      - cmake
      - git
      - libssl-dev
      - libyaml-dev
      - libncurses-dev
      - libc-ares-dev
      - libprotobuf-dev
      - protobuf-compiler
      - libjq-dev
      - libyaml-cpp-dev
      - libyaml-cpp-dev
      - libgrpc++-dev
      - protobuf-compiler-grpc
      - libcurl4-openssl-dev
      - libelf-dev
      - llvm
      - clang
{%- endif -%}
