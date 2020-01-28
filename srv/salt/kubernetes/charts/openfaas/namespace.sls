# -*- coding: utf-8 -*-
# vim: ft=jinja

{% import_yaml tpldir ~ "/defaults.yaml" or {} as defaults %}

openfaas-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/openfaas
    - name: /srv/kubernetes/manifests/openfaas/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/openfaas/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/openfaas/namespace.yaml