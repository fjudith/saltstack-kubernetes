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
    - use_vt: True
    - cwd: /srv/kubernetes/manifests/kubeless/
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
        
        until kubectl get pods --selector function=pubsub-python-nats --field-selector=status.phase=Running ;
          do printf '.' && sleep 1
        done

        kubectl logs -l function=pubsub-python-nats
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
{% endif %}