{%- set k8sVersion = pillar['kubernetes']['version'] -%}
{%- set os = salt['grains.get']('os') -%}
{%- set enableIPv6 = pillar['kubernetes']['node']['networking']['calico']['ipv6']['enable'] -%}
{%- set criProvider = pillar['kubernetes']['node']['runtime']['provider'] -%}

tiniproxy:
  pkg:
    - version: 17.12.1
    - installed
    - require:
      - pkgrepo: docker-ce-repo

/etc/tinyproxy.conf:
    file.managed:
    - source: salt://proxy/etc/tinyproxy.conf
    - user: root
    - template: jinja
    - group: root
    - mode: 444