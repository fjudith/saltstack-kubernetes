#! /bin/bash

set -e

ACTION=${ACTION:-$1}
USERNAME=${USERNAME:-$2}
PASSWORD=${PASSWORD:-$3}
URL=${URL:-$4}
REALM=${REALM:-$5}
REDIRECTURL=${REDIRECTURL:-$6}

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

## Create Realm
function create-realm {
  echo $TOKEN
  if ! http GET \
    "${URL}/auth/admin/realms" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e ".[] | select(.realm==\"${REALM}\")"
  then
    http --pretty=none POST \
      "${URL}/auth/admin/realms" \
      'Content-Type: application/json' \
      "Authorization: Bearer ${TOKEN}" < realms.json
  else
    echo "Realm already exists"
  fi
}

##################################################
# Create groups associated to Kubernetes RBAC
# keycloak group name | kubernetes cluster role
# ------------------- | -----------------------
# gitea-admins    | cluster-admin
# gitea-users     | view
##################################################
function create-groups {
    if ! http GET \
      "${URL}/auth/admin/realms/${REALM}/groups" \
      "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.name=="gitea-admins")'
    then
      http --pretty=none POST \
        "${URL}/auth/admin/realms/${REALM}/groups" \
        'Content-Type: application/json' \
        "Authorization: Bearer ${TOKEN}" < ${PWD}/admins-group.json
    else
      echo "gitea admins group already exists"
    fi

    if ! http GET \
      "${URL}/auth/admin/realms/${REALM}/groups" \
      "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.name=="gitea-users")'
    then
      http --pretty=none POST \
        "${URL}/auth/admin/realms/${REALM}/groups" \
        'Content-Type: application/json' \
        "Authorization: Bearer ${TOKEN}" < ${PWD}/users-group.json
    else
      echo "gitea users group already exists"
    fi
}

##################################################
# With recent keycloak version 4.6.0 and later,
# the client id is apparently no longer 
# automatically added to the audience field 'aud'
# of the access token. 
# Therefore even though the login succeeds
# the client rejects the user.
# To fix this you need to configure the audience 
# for your clients.
# (<https://github.com/keycloak/keycloak-documentation/blob/master/server_admin/topics/clients/oidc/audience.adoc>).
##################################################
function create-client-scopes {
  if ! http GET \
    "${URL}/auth/admin/realms/${REALM}/client-scopes" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.name=="allowed-services")'
  then
    http --pretty=none POST \
      "${URL}/auth/admin/realms/${REALM}/client-scopes" \
      'Content-Type: application/json' \
      "Authorization: Bearer ${TOKEN}" < client-scopes.json
  else
    echo "Allowed-services already exists"
  fi    
}

##################################################
# ## Kubernetes + Dashboard
# 1. Create the client "kubernetes" associated 
#    to the Keycloak Gatekeeper proxy. 
#    associated to "gitea-deck" Service.
# 2. Insert the audience protocol mapper associated 
#    to the "gitea" client in the "allowed-services"
#    client scopes.
# 3. Add the groups protocol mapper "groups" 
#    to the "gitea" client.
# 4. Add the client scopes "allowed-services"
#    to the "gitea" client.
# 5. Deploy the Keycloak Gatekeeper proxy.
# 6. Update the ingress resource "kubernetes-gitea"
#    to point to the Keycloak Gatekeeper proxy.
##################################################
function create-client {
   if ! http GET \
    "${URL}/auth/admin/realms/${REALM}/clients" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.clientId=="gitea")'
  then
    http --pretty=none POST \
      "${URL}/auth/admin/realms/${REALM}/clients" \
      'Content-Type: application/json' \
      "Authorization: Bearer ${TOKEN}" < client.json
  else
    echo "gitea client already exists"
  fi

  CSID=$(http GET \
    "${URL}/auth/admin/realms/${REALM}/client-scopes" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e -r '.[] | select(.name=="allowed-services") | .id'
  )

  if ! http GET \
    "${URL}/auth/admin/realms/${REALM}/client-scopes/${CSID}/protocol-mappers/models" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.name=="audience-gitea")'
  then
    http --pretty=none POST \
      "${URL}/auth/admin/realms/${REALM}/client-scopes/${CSID}/protocol-mappers/models" \
      'Content-Type: application/json' \
      "Authorization: Bearer ${TOKEN}" < protocolmapper.json
  else
    echo "gitea protocolmapper already exists"
  fi

  CID=$(http GET \
    "${URL}/auth/admin/realms/${REALM}/clients" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e -r '.[] | select(.clientId=="gitea") | .id'
  )

  if ! http GET \
    "${URL}/auth/admin/realms/${REALM}/clients/${CID}/protocol-mappers/models" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.name=="groups")'
  then
    http --pretty=none POST \
      "${URL}/auth/admin/realms/${REALM}/clients/${CID}/protocol-mappers/models" \
      'Content-Type: application/json' \
      "Authorization: Bearer ${TOKEN}" < groups-protocolmapper.json
  else
    echo "Groups protocolmapper already exists"
  fi

  if ! http GET \
    "${URL}/auth/admin/realms/${REALM}/clients/${CID}/protocol-mappers/models" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.name=="username")'
  then
    http --pretty=none POST \
      "${URL}/auth/admin/realms/${REALM}/clients/${CID}/protocol-mappers/models" \
      'Content-Type: application/json' \
      "Authorization: Bearer ${TOKEN}" < username-protocolmapper.json
  else
    echo "Username protocolmapper already exists"
  fi

  if ! http GET \
    "${URL}/auth/admin/realms/${REALM}/clients/${CID}/protocol-mappers/models" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.name=="userid")'
  then
    http --pretty=none POST \
      "${URL}/auth/admin/realms/${REALM}/clients/${CID}/protocol-mappers/models" \
      'Content-Type: application/json' \
      "Authorization: Bearer ${TOKEN}" < userid-protocolmapper.json
  else
    echo "Username protocolmapper already exists"
  fi

  if ! http GET \
    "${URL}/auth/admin/realms/${REALM}/clients/${CID}/default-client-scopes" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e ".[] | select(.id==\"${CSID}\")"
  then
    http --pretty=none PUT \
      "${URL}/auth/admin/realms/${REALM}/clients/${CID}/default-client-scopes/${CSID}" \
      "Authorization: Bearer ${TOKEN}"
  else
    echo "Default Client Scope 'allowed-services' already allocated"
  fi

  CLIENT_SECRET=$(http GET \
  "${URL}/auth/admin/realms/${REALM}/clients/${CID}/installation/providers/keycloak-oidc-keycloak-json" \
  "Authorization: Bearer ${TOKEN}" | jq -M -e -r .credentials.secret)
}


 case "$ACTION" in
    "create-realm" )
      #create-realm
      ;;
    "create-groups" )
      create-groups
      ;;
    "create-client-scopes" )
      create-client-scopes
      ;;
    "create-client" )
      create-client
      ;;
esac