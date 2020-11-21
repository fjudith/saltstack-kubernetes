#! /bin/bash

set -e


USERNAME=${USERNAME:-$1}
PASSWORD=${PASSWORD:-$2}
URL=${URL:-$3}
REALM=${REALM:-$4}

##################################################
# Authenticate to Keycloak and retreive session token
##################################################
TOKEN=$(http --ignore-stdin --form POST \
  "${URL}/auth/realms/master/protocol/openid-connect/token" \
  'Content-Type: application/x-www-form-urlencoded' \
  'grant_type=password' \
  'client_id=admin-cli' \
  "username=${USERNAME}" \
  "password=${PASSWORD}" | jq -M -e -r '.access_token')

CID=$(http GET \
    "${URL}/auth/admin/realms/${REALM}/clients" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e -r '.[] | select(.clientId=="gitea") | .id'
  )

http GET \
  "${URL}/auth/admin/realms/${REALM}/clients/${CID}/installation/providers/keycloak-oidc-keycloak-json" \
  "Authorization: Bearer ${TOKEN}" | jq -M -e -r .credentials.secret