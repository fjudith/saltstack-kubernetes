# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import proxyinjector with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

proxyinjector-demo:
  cmd.run:
    - watch:
      - cmd: proxyinjector
      - cmd: proxyinjector-demo-namespace
      - file: /srv/kubernetes/manifests/proxyinjector/kubehttpbin-values.yaml
    - cwd: /srv/kubernetes/manifests/proxyinjector/kubehttpbin/chart
    - runas: root
    - name: |
        helm upgrade --install kubehttpbin \
          --namespace kubehttpbin \
          --values /srv/kubernetes/manifests/proxyinjector/kubehttpbin-values.yaml \
          ./ --wait --timeout 3m

        {% if charts.get('keycloak', {'enabled': False}).enabled -%}
        {%- set keycloak_url = 'https://' + charts.get('keycloak', {}).get('ingress_host') + '.' + pillar['public-domain'] -%}
        {%- set keycloak_password = salt['cmd.shell']("kubectl get secret --namespace keycloak keycloak-http -o jsonpath='{.data.password}' | base64 --decode; echo") -%}
        {%- set client_secret     = salt['cmd.shell']('/srv/kubernetes/manifests/proxyinjector/kc-clientsecret-demo.sh' + ' ' + 'keycloak' + ' ' + keycloak_password + ' ' + keycloak_url + ' ' + charts.proxyinjector.oauth.keycloak.realm) -%}
        {%- set realm = charts.spinnaker.oauth.get('keycloak', {}).get('realm') -%}
        kubectl -n kubehttpbin annotate deployment/kubehttpbin \
        authproxy.stakater.com/discovery-url="{{ keycloak_url }}/auth/realms/{{ realm }}" \
        authproxy.stakater.com/client-id="demo" \
        authproxy.stakater.com/client-secret="{{ client_secret }}" \
        authproxy.stakater.com/gatekeeper-image="{{ proxyinjector.image }}" \
        authproxy.stakater.com/source-service-name="kubehttpbin" \
        authproxy.stakater.com/ressources="uri=/*" \
        authproxy.stakater.com/listen=":65080" \
        authproxy.stakater.com/upstream-url="https://{{ proxyinjector.ingress_host }}.{{ public_domain }}" \
        authproxy.stakater.com/target-port="8080" \
        authproxy.stakater.com/enabled="true"
        {% endif -%}

query-proxyinjector-demo:
  http.wait_for_successful_query:
    - watch:
      - cmd: proxyinjector-demo
      - cmd: proxyinjector-demo-ingress
    - name: https://{{ proxyinjector.ingress_host }}.{{ public_domain }}
    - wait_for: 120
    - request_interval: 5
    - status: 200