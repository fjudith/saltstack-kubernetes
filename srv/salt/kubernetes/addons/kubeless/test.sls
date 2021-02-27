# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{%- from tpldir ~ "/map.jinja" import kubeless with context %}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- set public_domain = pillar['public-domain'] %}

query-kubeless-ui:
  http.wait_for_successful_query:
    - watch:
      - cmd: kubeless-ui
      - cmd: kubeless-ingress
    - name: https://{{ kubeless.ingress_host }}.{{ public_domain }}/
    - wait_for: 120
    - request_interval: 5
    - status: 200

{% if common.addons.get('nats_operator', {'enabled': False}).enabled %}
test-kubeless-nats-pubsub:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/kubeless/test.py
        - http: query-kubeless-ui
        - cmd: kubeless-nats-trigger
    - runas: root
    - cwd: /srv/kubernetes/manifests/kubeless/
    - timeout: 120
    - name: |
        NATS_CLUSTER_IP=$(kubectl -n nats-io get service/nats-cluster -o jsonpath='{.spec.clusterIP}')

        # Function
        kubeless function deploy pubsub-python-nats --runtime python2.7 \
          --handler test.foobar \
          --from-file test.py
        
        # Trigger
        kubeless trigger nats create pubsub-python-nats --function-selector created-by=kubeless,function=pubsub-python-nats --trigger-topic test
        
        # Publishing
        kubeless trigger nats publish --url nats://${NATS_CLUSTER_IP}:4222 --topic test --message "Hello World!"

        until kubectl -n default get deployment pubsub-python-nats
        do 
          printf '.' && sleep 5
        done && \
        echo "" && \
        REPLICAS=$(kubectl -n default get deployment pubsub-python-nats -o jsonpath='{.status.replicas}') && \
        echo "Waiting for pubsub-python-nats to be up and running" && \
        while [ "$(kubectl -n default get deployment pubsub-python-nats -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n default logs -l function=pubsub-python-nats
    - onlyif: http --verify false https://localhost:6443/livez?verbose
{% endif %}