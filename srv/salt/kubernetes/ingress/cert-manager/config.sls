# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import cert_manager with context %}

/srv/kubernetes/manifests/cert-manager:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/cert-manager/00-crds.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/cert-manager
    - source: https://raw.githubusercontent.com/jetstack/cert-manager/v{{ cert_manager.version }}/deploy/manifests/00-crds.yaml
    - user: root
    - group: root
    - mode: 644
    - skip_verify: true

/srv/kubernetes/manifests/cert-manager/clusterissuer.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/cert-manager
    - source: salt://{{ tpldir }}/templates/{{ cert_manager.dns.provider }}-clusterissuer.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}