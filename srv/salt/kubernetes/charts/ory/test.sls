# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import ory with context %}
{%- set public_domain = pillar['public-domain'] -%}

hydra-oauth-client-test:
  cmd.run:
    - runas: root
    - name: |
        hydra clients create \
        --endpoint https://{{ ory.hydra.ingress_host }}-admin.{{ public_domain }}/ \
        --id my-client \
        --secret secret \
        -g client_credentials

        TOKEN=$(hydra token client \
        --endpoint https://{{ ory.hydra.ingress_host }}-public.{{ public_domain }}/ \
        --client-id my-client \
        --client-secret secret)

        hydra token introspect \
        --endpoint https://{{ ory.hydra.ingress_host }}-admin.{{ public_domain }}/ \
        --client-id my-client \
        --client-secret secret \
        ${TOKEN}

        hydra clients delete \
        --endpoint https://{{ ory.hydra.ingress_host }}-admin.{{ public_domain }}/ \
        my-client

hydra-oauth-authorization-test:
  cmd.run:
    - runas: root
    - name: |
        POD=$(kubectl -n ory get po -l app.kubernetes.io/name=hydra -o jsonpath='{.items[0].metadata.name}')

        kubectl -n ory exec ${POD} -c hydra -- hydra clients create \
        --endpoint https://{{ ory.hydra.ingress_host }}-admin.{{ public_domain }}/ \
        --id auth-code-client \
        --secret secret \
        --grant-types authorization_code,refresh_token \
        --response-types code,id_token \
        --scope openid,offline \
        --callbacks http://127.0.0.1:5555/callback

        kubectl -n ory exec ${POD} -c hydra -- hydra token user \
        --client-id auth-code-client \
        --client-secret secret \
        --endpoint https://{{ ory.hydra.ingress_host }}-public.{{ public_domain }}/ \
        --port 443 \
        --scope openid,offline \
        --no-open

        kubectl -n ory exec ${POD} -c hydra -- hydra clients delete \
        --endpoint https://{{ ory.hydra.ingress_host }}-admin.{{ public_domain }}/ \
        auth-code-client
