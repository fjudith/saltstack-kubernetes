

{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}

/usr/bin/kubectl:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ common.version }}/bin/linux/amd64/kubectl
    - skip_verify: true
    - show_changes: False
    - group: root
    - mode: 755

azure-cli:
  pkgrepo.managed:
    - name: deb https://packages.microsoft.com/repos/azure-cli/ bionic main
    - dist: bionic
    - file: /etc/apt/sources.list.d/azure-cli.list
    - gpgcheck: 1
    - key_url: https://packages.microsoft.com/keys/microsoft.asc
  pkg.latest:
    - name: azure-cli
    - refresh: true