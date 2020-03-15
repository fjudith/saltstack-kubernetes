# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import cert_manager with context %}

/srv/kubernetes/manifests/cert-manager:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/cert-manager/00-crds.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/cert-manager
    - source: https://github.com/jetstack/cert-manager/releases/download/v{{ cert_manager.version }}/cert-manager.crds.yaml
    - user: root
    - group: root
    - mode: "0644"
    - skip_verify: true

/srv/kubernetes/manifests/cert-manager/clusterissuer.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/cert-manager
    - source: salt://{{ tpldir }}/templates/clusterissuer.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}