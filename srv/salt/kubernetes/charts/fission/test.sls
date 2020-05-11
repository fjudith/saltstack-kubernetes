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

fission-fortunewhale-workflow:
  cmd.run:
    - require:
      - file: /usr/local/bin/fission
    - user: root
    - group: root
    - cwd: /tmp
    - name: |
        FISSION_ROUTER="http:// $(kubectl -n fission get svc router -o jsonpath='{.spec.clusterIP}')"
        fission env create --name binary --image fission/binary-env && \
        curl https://raw.githubusercontent.com/fission/fission-workflows/master/examples/whales/fortune.sh > fortune.sh && \
        curl https://raw.githubusercontent.com/fission/fission-workflows/master/examples/whales/whalesay.sh > whalesay.sh && \
        fission fn create --name whalesay --env binary --deploy ./whalesay.sh && \
        fission fn create --name fortune --env binary --deploy ./fortune.sh && \
        curl https://raw.githubusercontent.com/fission/fission-workflows/master/examples/whales/fortunewhale.wf.yaml > fortunewhale.wf.yaml && \
        fission fn create --name fortunewhale --env workflow --src ./fortunewhale.wf.yaml && \
        curl $FISSION_ROUTER/fission-function/fortunewhale && \
        fission env delete --name binary && \
        rm -f fortune.sh whalesay.sh fortunewhale.wf.yaml


