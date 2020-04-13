# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import fission with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

fission-hello-world:
  cmd.run:
    - require: 
      - file: /usr/local/bin/fission
    - user: root
    - group: root
    - cwd: /tmp
    - name: |
        fission env create --name nodejs --image fission/node-env && \
        curl https://raw.githubusercontent.com/fission/fission/{{ fission.version }}/examples/nodejs/hello.js > hello.js && \
        fission function create --name hello --env nodejs --code hello.js && \
        fission function test --name hello &&  \
        fission env delete --name nodejs && \
        rm -f hello.js
