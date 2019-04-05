#! /bin/bash
# https://www.ctl.io/developers/blog/post/curl-vs-httpie-http-apis
# https://www.keycloak.org/docs-api/5.0/rest-api/index.html
# https://httpie.org/doc
set -ex

ACTION=${1}
USERNAME=${2}
PASSWORD=${3}
URL=${4}
REALM=${5}
REDIRECTURL=${6}

# Authenticate to Keycloak and retreive session token
TOKEN=$(http --form POST \
  "${URL}/auth/realms/master/protocol/openid-connect/token" \
  'Content-Type: application/x-www-form-urlencoded' \
  'grant_type=password' \
  'client_id=admin-cli' \
  "username=${USERNAME}" \
  "password=${PASSWORD}" | jq -M -e -r '.access_token')


## Create Realm
function create-realm {
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

## Create Groups
function create-groups {
    if ! http GET \
      "${URL}/auth/admin/realms/${REALM}/groups" \
      "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.name=="kubernetes-admins")'
    then
      http --pretty=none POST \
        "${URL}/auth/admin/realms/${REALM}/groups" \
        'Content-Type: application/json' \
        "Authorization: Bearer ${TOKEN}" < keycloak-kubernetes-admins-group.json
    else
      echo "Kubernetes admins group already exists"
    fi

    if ! http GET \
      "${URL}/auth/admin/realms/${REALM}/groups" \
      "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.name=="kubernetes-users")'
    then
      http --pretty=none POST \
        "${URL}/auth/admin/realms/${REALM}/groups" \
        'Content-Type: application/json' \
        "Authorization: Bearer ${TOKEN}" < keycloak-kubernetes-users-group.json
    else
      echo "Kubernetes users group already exists"
    fi
}

### Create Client Scopes to accept to fix client_id no longer added to the audience field 'aud'
### https://stackoverflow.com/questions/53550321/keycloak-gatekeeper-aud-claim-and-client-id-do-not-match
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

## Create client for Kubernetes Dashboard
function create-client-kubernetes {
   if ! http GET \
    "${URL}/auth/admin/realms/${REALM}/clients" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.clientId=="kubernetes")'
  then
    http --pretty=none POST \
      "${URL}/auth/admin/realms/${REALM}/clients" \
      'Content-Type: application/json' \
      "Authorization: Bearer ${TOKEN}" < kubernetes-dashboard.json
  else
    echo "Kubernetes client already exists"
  fi

  CSID=$(http GET \
    "${URL}/auth/admin/realms/${REALM}/client-scopes" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e -r '.[] | select(.name=="allowed-services") | .id'
  )

  if ! http GET \
    "${URL}/auth/admin/realms/${REALM}/client-scopes/${CSID}/protocol-mappers/models" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.name=="audience-kubernetes")'
  then
    http --pretty=none POST \
      "${URL}/auth/admin/realms/${REALM}/client-scopes/${CSID}/protocol-mappers/models" \
      'Content-Type: application/json' \
      "Authorization: Bearer ${TOKEN}" < kubernetes-dashboard-protocolmapper.json
  else
    echo "Kubernetes protocolmapper already exists"
  fi

  CID=$(http GET \
    "${URL}/auth/admin/realms/${REALM}/clients" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e -r '.[] | select(.clientId=="kubernetes") | .id'
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

  CLIENT_SECRET=$(http GET \
  "${URL}/auth/admin/realms/${REALM}/clients/kubernetes/installation/providers/keycloak-oidc-keycloak-json" \
  "Authorization: Bearer ${TOKEN}" | jq -M -e -r .credentials.secret)

  # Deploy the gateway in the `kube-system` namespace
  helm template /srv/kubernetes/charts/incubator/keycloak-gatekeeper \
    --name kubernetes-dashboard \
    --namespace kube-system \
    --set discoveryUrl=${URL}/auth/realms/${REALM} \
    --set clientId=kubernetes \
    --set clientSecret=${CLIENT_SECRET} \
    --set redirectionUrl=${REDIRECTURL} \
    --set upstreamUrl=https://kubernetes-dashboard.kube-system.svc.cluster.local | kubectl apply -n kube-system -f -
  
  # Bind Keycloak authenticated users with the appropriate Kubernetes role.
  kubectl apply -f ./files/keycloak-kubernetes-rbac.yaml

  # Update the istio ingress virtualservice to point to the `keycloak-gatekeeper`.
  kubectl patch virtualservice kubernetes-dashboard --type json \
  --patch='[{"op": "replace", "path": "/spec/http/0/route/0/destination/host", "value": "kubernetes-dashboard-keycloak-gatekeeper.kube-system.svc.cluster.local"}]'

  kubectl patch virtualservice kubernetes-dashboard --type json \
  --patch='[{"op": "replace", "path": "/spec/http/0/route/0/destination/port/number", "value": 3000}]'
}

function create-client-weave-scope {
   if ! http GET \
    "${URL}/auth/admin/realms/${REALM}/clients" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.clientId=="weave-scope")'
  then
    http --pretty=none POST \
      "${URL}/auth/admin/realms/${REALM}/clients" \
      'Content-Type: application/json' \
      "Authorization: Bearer ${TOKEN}" < weave-scope.json
  else
    echo "Weave-scope client already exists"
  fi

  CSID=$(http GET \
    "${URL}/auth/admin/realms/${REALM}/client-scopes" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e -r '.[] | select(.name=="allowed-services") | .id'
  )

  if ! http GET \
    "${URL}/auth/admin/realms/${REALM}/client-scopes/${CSID}/protocol-mappers/models" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.name=="audience-weave-scope")'
  then
    http --pretty=none POST \
      "${URL}/auth/admin/realms/${REALM}/client-scopes/${CSID}/protocol-mappers/models" \
      'Content-Type: application/json' \
      "Authorization: Bearer ${TOKEN}" < weave-scope-protocolmapper.json
  else
    echo "Weave-scope protocolmapper already exists"
  fi

  CLIENT_SECRET=$(http GET \
  "${URL}/auth/admin/realms/${REALM}/clients/weave-scope/installation/providers/keycloak-oidc-keycloak-json" \
  "Authorization: Bearer ${TOKEN}" | jq -M -e -r .credentials.secret)

  # Deploy the gateway in the `kube-system` namespace
  helm template /srv/kubernetes/charts/incubator/keycloak-gatekeeper \
    --name weave-scope-app \
    --namespace weave \
    --set discoveryUrl=${URL}/auth/realms/${REALM} \
    --set clientId=weave-scope \
    --set clientSecret=${CLIENT_SECRET} \
    --set redirectionUrl=${REDIRECTURL} \
    --set upstreamUrl=http://weave-scope-app.weave.svc.cluster.local | kubectl apply -n weave -f -

  # Update the istio ingress virtualservice to point to the `keycloak-gatekeeper`.
  kubectl patch virtualservice weave-scope --type json \
  --patch='[{"op": "replace", "path": "/spec/http/0/route/0/destination/host", "value": "weave-scope-app-keycloak-gatekeeper.weave.svc.cluster.local"}]'
  
  kubectl patch virtualservice weave-scope --type json \
  --patch='[{"op": "replace", "path": "/spec/http/0/route/0/destination/port/number", "value": 3000}]'
}

case "$1" in
    "create-realm" )
      create-realm
      ;;
    "create-groups" )
      create-groups
      ;;
    "create-client-scopes" )
      create-client-scopes
      ;;
    "create-client-kubernetes" )
      create-client-kubernetes
      ;;
    "create-client-weave-scope" )
      create-client-weave-scope
      ;;
esac