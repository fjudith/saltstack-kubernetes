# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{%- from tpldir ~ "/map.jinja" import crio with context %}

/etc/cni/net.d/200-loopback.conf:
  file.absent:
    - watch:
      - pkg: cri-o-{{ crio.version }}

/etc/containers:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/etc/containers/oci/hooks.d:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/etc/containers/policy.json:
  file.managed:
    - require:
      - file: /etc/containers
    - source: salt://{{ tpldir }}/files/policy.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/etc/crio/seccomp.json:
  file.managed:
    - require:
      - file: /etc/containers
    - source: salt://{{ tpldir }}/files/seccomp.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/etc/crio:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0755"
    - makedirs: True

/lib/systemd/system/crio.service:
  file.managed:
    - require:
      - file: /etc/crio
    - source: salt://{{ tpldir }}/files/crio.service
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/lib/systemd/system/crio-shutdown.service:
  file.managed:
    - require:
      - file: /etc/crio
    - source: salt://{{ tpldir }}/files/crio-shutdown.service
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/etc/crio/crio.conf:
  file.managed:
    - require:
      - file: /etc/crio
    - source: salt://{{ tpldir }}/files/crio.conf
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

crio.service:
  service.running:
    - watch:
      - pkg: cri-o-{{ crio.version }}
      - file: /lib/systemd/system/crio.service
      - file: /etc/crio/crio.conf
      - file: /etc/crio/seccomp.json
      - file: /etc/containers/policy.json
      - file: /etc/cni/net.d/100-crio-bridge.conf
      - file: /etc/cni/net.d/200-loopback.conf
    - enable: True