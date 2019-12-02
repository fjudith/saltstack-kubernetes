

{%- from "kubernetes/role/master/kubeadm/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}

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

ceph-common:
  pkg.latest:
    - refresh: true

httpie:
  pkg.latest:
    - refresh: true

jq:
  pkg.latest:
    - refresh: true