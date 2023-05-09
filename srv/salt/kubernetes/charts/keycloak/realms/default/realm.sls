# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import keycloak with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- set keycloak_url = keycloak.ingress.host ~ '.' ~ public_domain -%}
{%- set keycloak_username = salt['cmd.shell'](
  'kubectl --namespace=keycloak get configmap keycloak-env-vars --output=jsonpath="{.data.KEYCLOAK_ADMIN}"'
  ) %}
{%- set keycloak_password = salt['cmd.shell'](
  'kubectl --namespace=keycloak get secret keycloak --output=jsonpath="{.data.admin-password}" | base64 -d'
  ) %}
{%- set keycloak_token = salt['cmd.shell'](
  'http --pretty=none --form POST https://' ~ keycloak_url ~ '/auth/realms/master/protocol/openid-connect/token "Content-Type: application/x-www-form-urlencoded" grant_type=password client_id=admin-cli username=' ~ keycloak_username ~ ' password=' ~ keycloak_password ~ '| jq -M -e -r ".access_token"'
  ) %}

/srv/keycloak/realms/default:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

# /srv/keycloak/realms/default/header:
#   file.managed:
#     - require:
#       - file: /srv/keycloak/realms/default
#     - source: salt://{{ tpldir }}/templates/header.j2
#     - user: root
#     - group: root
#     - template: jinja
#     - mode: "0644"
#     - context:
#       tpldir: {{ tpldir }}

keycloak-default-realm:
  file.managed:
    - require:
      - file: /srv/keycloak/realms/default
    - name: /srv/keycloak/realms/default/realms.json
    - source: salt://{{ tpldir }}/templates/realms.json.j2
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  # http.query:
  #   - require:
  #     - file: /srv/keycloak/realms/default/realms.json
  #   - name: https://{{ keycloak_url }}/auth/admin/realms
  #   - method: POST
  #   - header_dict:
  #       Content-Type: application/json
  #       Authorization: Bearer {{ keycloak_token }}
  #   - data_file: /srv/keycloak/realms/default/realms.json
