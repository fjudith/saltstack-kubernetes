# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import portworx with context %}

portworx-storageclass:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/portworx
    - name: /srv/kubernetes/manifests/portworx/storage-class.yaml
    - source: salt://{{ tpldir }}/templates/storage-class.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: portworx
    - watch:
      - file: /srv/kubernetes/manifests/portworx/storage-class.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/portworx/storage-class.yaml

{% if portworx.get('default_storageclass', {'enabled': False}).enabled %}
portworx-default-storageclass:
  cmd.run:
    - require:
      - cmd: portworx-storageclass
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: |
        kubectl patch storageclass {{ portworx.default_storageclass.name }} -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' 
{% endif %}