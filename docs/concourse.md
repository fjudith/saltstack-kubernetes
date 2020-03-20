# Concourse

Concourse deployment is enabled by the following pillar data.

> Helm [stable](https://github.com/helm/charts/tree/master/stable/concourse) chart is leveraged to ensure long-term support.
> the `source_hash` value required to download the `fly` client can be retreived in the [Concourse release page](https://github.com/concourse/concourse/releases)

```yaml
  charts:
    concourse:
      enabled: true
      db_password: V3ry1ns3sur3P4ssw0rd
      db_size: 8Gi
      version: 5.7.0
      source_hash: 5897cdd75f7ca2b0edace95eb088ec5585575d28
      ingress_host: concourse
```

If [Keycloak](./keycloak.md) pillar is enabled. Courcourse will be configured to perform a [Genenic Oauth](https://concourse-ci.org/generic-oauth.html) user authication againts the Keycloak instance running inside the Kubernetes cluster, instead of the default local authentication.

```yaml
  charts:
    concourse:
      enabled: true
      db_password: V3ry1ns3sur3P4ssw0rd
      db_size: 8Gi
      version: 5.7.0
      source_hash: 5897cdd75f7ca2b0edace95eb088ec5585575d28
      ingress_host: concourse
      oauth:
        provider: keycloak
        keycloak:
          realm: default
```

To manually deploy Concourse, run the following command line from the **Salt-Master** (i.e. edge01).

```bash
salt -G role:master state.apply kubernetes.charts.concourse
```

## Download Concourse client

Download the appropriate `fly` client version.

```bash
VERSION='5.7.0'
curl -L https://github.com/concourse/concourse/releases/download/v${VERSION}/fly-${VERSION}-linux-amd64.tgz | tar xvzf - && \
mv fly /usr/local/bin
```

## Troubleshooting

### Oauth flow

Check if Keycloak is accessible via the Ingress Controller using [httpie](https://httpie.org) and [jq](https://stedolan.github.io/jq/).

```bash
# Retreive Keycloak client Secret
KEYCLOAK_URL=$(kubectl get ingress -n keycloak keycloak -o jsonpath={.spec.rules[0].host})
KEYCLOAK_ADMIN='keycloak'
KEYCLOAK_PASSWORD=$(kubectl get secret --namespace keycloak keycloak-http -o jsonpath="{.data.password}" | base64 --decode; echo)
CONCOURSE_REALM='default'
CONCOURSE_URL=$(kubectl get ingress -n concourse concourse-dashboard -o jsonpath={.spec.rules[0].host})
CONCOURSE_USERNAME='<concourse oauth user>'
CONCOURSE_PASSWORD='<concourse oauth password>'
CONCOURSE_TEAM='concourse-admins'

TOKEN=$(http --ignore-stdin --form POST \
  "${KEYCLOAK_URL}/auth/realms/master/protocol/openid-connect/token" \
  'Content-Type: application/x-www-form-urlencoded' \
  'grant_type=password' \
  'client_id=admin-cli' \
  "username=${KEYCLOAK_ADMIN}" \
  "password=${KEYCLOAK_PASSWORD}" | jq -M -e -r '.access_token')

CID=$(http GET \
    "${KEYCLOAK_URL}/auth/admin/realms/${CONCOURSE_REALM}/clients" \
    "Authorization: Bearer ${TOKEN}" | jq -M -e -r '.[] | select(.clientId=="concourse") | .id'
  )

CONCOURSE_CLIENT_SECRET=$(http GET \
  "${KEYCLOAK_URL}/auth/admin/realms/${CONCOURSE_REALM}/clients/${CID}/installation/providers/keycloak-oidc-keycloak-json" \
  "Authorization: Bearer ${TOKEN}" | jq -M -e -r .credentials.secret)

CONCOURSE_TOKEN=$(http --ignore-stdin --form POST \
  "${KEYCLOAK_URL}/auth/realms/${CONCOURSE_REALM}/protocol/openid-connect/token" \
  'Content-Type: application/x-www-form-urlencoded' \
  'grant_type=password' \
  'client_id=concourse' \
  "client_secret=${CONCOURSE_CLIENT_SECRET}" \
  "username=${CONCOURSE_USERNAME}" \
  "password=${CONCOURSE_PASSWORD}" | jq -M -e -r '.access_token')

http --ignore-stdin --form POST \
  "${CONCOURSE_URL}/sky/token" \
  "Authorization: Bearer ${CONCOURSE_TOKEN}" \
  'scope': 'openid profile email federated:id groups'


cat <<EOF | tee -a ~/.flyrc
targets:
  concourse:
    api: ${CONCOURSE_URL}
    team: ${CONCOURSE_TEAM}
    token:
      type: Bearer
      value: ${CONCOURSE_TOKEN}
EOF
```
