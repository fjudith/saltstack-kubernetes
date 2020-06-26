# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import longhorn with context %}

{% if longhorn.get('default_storageclass', {'enabled': False}).enabled %}
longhorn-default-storageclass:
  cmd.run:
    - require:
      - cmd: longhorn
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
    - name: |
        kubectl patch storageclass {{ longhorn.default_storageclass.name }} -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' 
{% endif %}