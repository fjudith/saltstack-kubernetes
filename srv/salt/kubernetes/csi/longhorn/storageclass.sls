# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import longhorn with context %}

{% if longhorn.get('default_storageclass', {'enabled': False}).enabled %}
longhorn-default-storageclass:
  cmd.run:
    - require:
      - cmd: longhorn
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: |
        kubectl patch storageclass {{ longhorn.default_storageclass.name }} -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' 
{% endif %}