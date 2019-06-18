#! /bin/bash

set -e

ACTION=${1}
USERNAME=${2}
PASSWORD=${3}
URL=${4}
REALM=${5}
REDIRECTURL=${6}

##################################################
# Authenticate to Keycloak and retreive session token
##################################################
TOKEN=$(http --pretty=none --form POST \
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

##################################################
# Create groups associated to Kubernetes RBAC
# keycloak group name | kubernetes cluster role
# ------------------- | -----------------------
# kubernetes-admins   | cluster-admin
# kubernets-users     | view
##################################################
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
#    associated to "kubernetes-dashboard" Service.
# 2. Insert the audience protocol mapper associated 
#    to the "kubernetes" client in the "allowed-services"
#    client scopes.
# 3. Add the groups protocol mapper "groups" 
#    to the "kubernetes" client.
# 4. Add the client scopes "allowed-services"
#    to the "kubernetes" client.
# 5. Deploy the Keycloak Gatekeeper proxy.
# 6. Update the ingress resource "kubernetes-dashboard"
#    to point to the Keycloak Gatekeeper proxy.
##################################################
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

  # Deploy the gateway in the `kube-system` namespace
  helm template /srv/kubernetes/charts/incubator/keycloak-gatekeeper \
    --name kubernetes-dashboard \
    --namespace kube-system \
    --set discoveryUrl=${URL}/auth/realms/${REALM} \
    --set clientId=kubernetes \
    --set clientSecret=${CLIENT_SECRET} \
    --set redirectionUrl=${REDIRECTURL} \
    --set upstreamUrl=https://kubernetes-dashboard.kube-system | kubectl apply -n kube-system -f -
  
  # Bind Keycloak authenticated users with the appropriate Kubernetes role.
  kubectl apply -f ./files/keycloak-kubernetes-rbac.yaml

  # Update the ingress to point to the `keycloak-gatekeeper`.
  kubectl patch ingress -n kube-system kubernetes-dashboard --type json \
  --patch='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/serviceName", "value": "kubernetes-dashboard-keycloak-gatekeeper"}]'

  kubectl patch ingress -n kube-system kubernetes-dashboard --type json \
  --patch='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/servicePort", "value": 3000}]'
}

##################################################
# ## Weave Scope
# 1. Create the client "weave-scope" associated 
#    to the Keycloak Gatekeeper pod. 
#    associated to "weave-scope-app" Service.
# 2. Insert the audience protocol mapper associated 
#    to the "weave-scope" client in the "allowed-services"
#    client scopes.
# 3. Add the groups protocol mapper "groups" 
#    to the "weave-scope" client.
# 4. Add the client scopes "allowed-services"
#    to the "weave-scope" client.
# 5. Deploy the Keycloak Gatekeeper proxy.
# 6. Update the ingress resource "weave-scope"
#    to point to the Keycloak Gatekeeper proxy.
##################################################
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

  CID=$(http GET \
    "${URL}/auth/admin/realms/${REALM}/clients" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e -r '.[] | select(.clientId=="weave-scope") | .id'
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

  # Deploy the gateway in the `kube-system` namespace
  helm template /srv/kubernetes/charts/incubator/keycloak-gatekeeper \
    --name weave-scope-app \
    --namespace weave \
    --set discoveryUrl=${URL}/auth/realms/${REALM} \
    --set clientId=weave-scope \
    --set clientSecret=${CLIENT_SECRET} \
    --set redirectionUrl=${REDIRECTURL} \
    --set upstreamUrl=http://weave-scope-app.weave | kubectl apply -n weave -f -

  # Update the ingress to point to the `keycloak-gatekeeper`.
  kubectl patch ingress -n weave weave-scope --type json \
  --patch='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/serviceName", "value": "weave-scope-app-keycloak-gatekeeper"}]'
  
  kubectl patch ingress -n weave weave-scope --type json \
  --patch='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/servicePort", "value": 3000}]'
}

##################################################
# ## Kube-Prometheus - AlertManager
# 1. Create the client "alertmanager" associated 
#    to the Keycloak Gatekeeper pod. 
#    associated to "alertmanager-main" Service.
# 2. Insert the audience protocol mapper associated 
#    to the "weave-scope" client in the "alertmanager"
#    client scopes.
# 3. Add the groups protocol mapper "groups" 
#    to the "alertmanager" client.
# 4. Add the client scopes "allowed-services"
#    to the "alertmanager" client.
# 5. Deploy the Keycloak Gatekeeper proxy.
# 6. Update the ingress resource "alertmanager"
#    to point to the Keycloak Gatekeeper proxy.
##################################################
function create-client-alertmanager {
   if ! http GET \
    "${URL}/auth/admin/realms/${REALM}/clients" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.clientId=="alertmanager")'
  then
    http --pretty=none POST \
      "${URL}/auth/admin/realms/${REALM}/clients" \
      'Content-Type: application/json' \
      "Authorization: Bearer ${TOKEN}" < alertmanager.json
  else
    echo "AlertManager client already exists"
  fi

  CSID=$(http GET \
    "${URL}/auth/admin/realms/${REALM}/client-scopes" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e -r '.[] | select(.name=="allowed-services") | .id'
  )

  if ! http GET \
    "${URL}/auth/admin/realms/${REALM}/client-scopes/${CSID}/protocol-mappers/models" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.name=="audience-alertmanager")'
  then
    http --pretty=none POST \
      "${URL}/auth/admin/realms/${REALM}/client-scopes/${CSID}/protocol-mappers/models" \
      'Content-Type: application/json' \
      "Authorization: Bearer ${TOKEN}" < alertmanager-protocolmapper.json
  else
    echo "AlertManager protocolmapper already exists"
  fi

  CID=$(http GET \
    "${URL}/auth/admin/realms/${REALM}/clients" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e -r '.[] | select(.clientId=="alertmanager") | .id'
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

  # Deploy the gateway in the `kube-system` namespace
  helm template /srv/kubernetes/charts/incubator/keycloak-gatekeeper \
    --name alertmanager \
    --namespace monitoring \
    --set discoveryUrl=${URL}/auth/realms/${REALM} \
    --set clientId=alertmanager \
    --set clientSecret=${CLIENT_SECRET} \
    --set redirectionUrl=${REDIRECTURL} \
    --set upstreamUrl=http://alertmanager-main.monitoring:9093 | kubectl apply -n monitoring -f -

  # Update the ingress to point to the `keycloak-gatekeeper`.
  kubectl patch ingress -n monitoring alertmanager --type json \
  --patch='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/serviceName", "value": "alertmanager-keycloak-gatekeeper"}]'
  
  kubectl patch ingress -n monitoring alertmanager --type json \
  --patch='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/servicePort", "value": 3000}]'
}

##################################################
# ## Kube-Prometheus - Prometheus
# 1. Create the client "prometheus" associated 
#    to the Keycloak Gatekeeper pod. 
#    associated to "prometheus-k8s" Service.
# 2. Insert the audience protocol mapper associated 
#    to the "prometheus" client in the "alertmanager"
#    client scopes.
# 3. Add the groups protocol mapper "groups" 
#    to the "alertmanager" client.
# 4. Add the client scopes "allowed-services"
#    to the "prometheus" client.
# 5. Deploy the Keycloak Gatekeeper proxy.
# 6. Update the ingress resource "prometheus"
#    to point to the Keycloak Gatekeeper proxy.
##################################################
function create-client-prometheus {
   if ! http GET \
    "${URL}/auth/admin/realms/${REALM}/clients" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.clientId=="prometheus")'
  then
    http --pretty=none POST \
      "${URL}/auth/admin/realms/${REALM}/clients" \
      'Content-Type: application/json' \
      "Authorization: Bearer ${TOKEN}" < prometheus.json
  else
    echo "Prometheus client already exists"
  fi

  CSID=$(http GET \
    "${URL}/auth/admin/realms/${REALM}/client-scopes" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e -r '.[] | select(.name=="allowed-services") | .id'
  )

  if ! http GET \
    "${URL}/auth/admin/realms/${REALM}/client-scopes/${CSID}/protocol-mappers/models" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.name=="audience-prometheus")'
  then
    http --pretty=none POST \
      "${URL}/auth/admin/realms/${REALM}/client-scopes/${CSID}/protocol-mappers/models" \
      'Content-Type: application/json' \
      "Authorization: Bearer ${TOKEN}" < prometheus-protocolmapper.json
  else
    echo "Prometheus protocolmapper already exists"
  fi

  CID=$(http GET \
    "${URL}/auth/admin/realms/${REALM}/clients" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e -r '.[] | select(.clientId=="prometheus") | .id'
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

  # Deploy the gateway in the `kube-system` namespace
  helm template /srv/kubernetes/charts/incubator/keycloak-gatekeeper \
    --name prometheus \
    --namespace monitoring \
    --set discoveryUrl=${URL}/auth/realms/${REALM} \
    --set clientId=prometheus \
    --set clientSecret=${CLIENT_SECRET} \
    --set redirectionUrl=${REDIRECTURL} \
    --set upstreamUrl=http://prometheus-k8s.monitoring:9090 | kubectl apply -n monitoring -f -

  # Update the ingress to point to the `keycloak-gatekeeper`.
  kubectl patch ingress -n monitoring prometheus --type json \
  --patch='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/serviceName", "value": "prometheus-keycloak-gatekeeper"}]'
  
  kubectl patch ingress -n monitoring prometheus --type json \
  --patch='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/servicePort", "value": 3000}]'
}

##################################################
# ## Rook-Ceph - Ceph Mgr Dashboard
# 1. Create the client "rook-ceph" associated 
#    to the Keycloak Gatekeeper pod. 
#    associated to "rook-ceph-mgr-dashboard" Service.
# 2. Insert the audience protocol mapper associated 
#    to the "rook-ceph" client in the "alertmanager"
#    client scopes.
# 3. Add the groups protocol mapper "groups" 
#    to the "rook-ceph" client.
# 4. Add the client scopes "allowed-services"
#    to the "rook-ceph" client.
# 5. Deploy the Keycloak Gatekeeper proxy.
# 6. Update the ingress resource "rook-ceph-mgr-dashboard"
#    to point to the Keycloak Gatekeeper proxy.
##################################################
function create-client-rook-ceph {
  if ! http GET \
    "${URL}/auth/admin/realms/${REALM}/clients" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.clientId=="rook-ceph")'
  then
    http --pretty=none POST \
      "${URL}/auth/admin/realms/${REALM}/clients" \
      'Content-Type: application/json' \
      "Authorization: Bearer ${TOKEN}" < rook-ceph.json
  else
    echo "Rook-Ceph client already exists"
  fi

  CSID=$(http GET \
    "${URL}/auth/admin/realms/${REALM}/client-scopes" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e -r '.[] | select(.name=="allowed-services") | .id'
  )

  if ! http GET \
    "${URL}/auth/admin/realms/${REALM}/client-scopes/${CSID}/protocol-mappers/models" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e '.[] | select(.name=="audience-rook-ceph")'
  then
    http --pretty=none POST \
      "${URL}/auth/admin/realms/${REALM}/client-scopes/${CSID}/protocol-mappers/models" \
      'Content-Type: application/json' \
      "Authorization: Bearer ${TOKEN}" < rook-ceph-protocolmapper.json
  else
    echo "Rook-Ceph protocolmapper already exists"
  fi

  CID=$(http GET \
    "${URL}/auth/admin/realms/${REALM}/clients" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e -r '.[] | select(.clientId=="rook-ceph") | .id'
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

  # Deploy the gateway in the `kube-system` namespace
  helm template /srv/kubernetes/charts/incubator/keycloak-gatekeeper \
    --name rook-ceph-mgr-dashboard \
    --namespace rook-ceph \
    --set discoveryUrl=${URL}/auth/realms/${REALM} \
    --set clientId=rook-ceph \
    --set clientSecret=${CLIENT_SECRET} \
    --set redirectionUrl=${REDIRECTURL} \
    --set upstreamUrl=https://rook-ceph-mgr-dashboard.rook-ceph:8443 | kubectl apply -n rook-ceph -f -

  # Update the ingress to point to the `keycloak-gatekeeper`.
  kubectl patch ingress -n rook-ceph rook-ceph-mgr-dashboard --type json \
  --patch='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/serviceName", "value": "rook-ceph-mgr-dashboard-keycloak-gatekeeper"}]'
  
  kubectl patch ingress -n rook-ceph rook-ceph-mgr-dashboard --type json \
  --patch='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/servicePort", "value": 3000}]'
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
    "create-client-alertmanager" )
      create-client-alertmanager
      ;;
    "create-client-prometheus" )
      create-client-prometheus
      ;;
    "create-client-rook-ceph" )
      create-client-rook-ceph
      ;;
esac