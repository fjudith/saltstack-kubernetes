# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import openebs with context %}

openebs-cstor-storageclass:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/openebs
    - name: /srv/kubernetes/manifests/openebs/cstor-storage-class.yaml
    - source: salt://{{ tpldir }}/templates/cstor-storage-class.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: openebs-cstor
    - watch:
      - file: /srv/kubernetes/manifests/openebs/cstor-storage-class.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/openebs/cstor-storage-class.yaml

{% if openebs.get('default_storageclass', {'enabled': False}).enabled %}
openebs-default-cstor-storageclass:
  cmd.run:
    - require:
      - cmd: openebs-cstor-storageclass
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: |
        kubectl patch storageclass {{ openebs.default_storageclass.name }} -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' 
{% endif %}