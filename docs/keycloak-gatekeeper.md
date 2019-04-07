# Keycloak-Gatekeeper

An OpenID-Connect authentication proxy to protect exposed services that do not support authentication.

Deployment is enabled by the following pillar data.


> _Helm [stable](https://github.com/fjudith/charts/tree/master/incubator/keycloak-gatekeeper) chart is leveraged to ensure long-term support._

```yaml
public-domain: domain.tld
kubernetes:
  addons:
    dashboard:
      enabled: true
    weave_scope:
      enabled: True
      image: docker.io/weaveworks/scope:1.10.2
    kube_prometheus:
      enabled: True
      version: 0.29.0
  charts:
    keycloak_gatekeeper:
      enabled: true
      version: "master"
      realm: "default"
      groups:
        - "kubernetes-admins,cluster-admin"
        - "kubernetes-users,view"
```

To manually deploy Keycloak-Gatekeeper, run the following command line from the **Salt-Master** (i.e. proxy01).

```bash
salt -G role:master state.apply kubernetes.charts.keycloak-gatekeeper
```

## Troubleshooting

Check if Keycloak is accessible via the Istio Ingress Gateway.

```bash
curl -IL https://kubernetes-dashboard.example.com
```

```text
HTTP/1.1 307 Temporary Redirect
content-type: text/html; charset=utf-8
location: /oauth/authorize?state=94d9198f-3fc9-4712-8f9b-493ea95552e1
set-cookie: request_uri=Lw==; Path=/; Domain=kubernetes-dashboard.example.com; HttpOnly; Secure
set-cookie: OAuth_Token_Request_State=94d9198f-3fc9-4712-8f9b-493ea95552e1; Path=/; Domain=kubernetes-dashboard.example.com; HttpOnly; Secure
date: Fri, 05 Apr 2019 20:25:37 GMT
x-envoy-upstream-service-time: 1
server: istio-envoy
transfer-encoding: chunked

HTTP/1.1 307 Temporary Redirect
content-type: text/html; charset=utf-8
location: https://sso.example.com/auth/realms/default/protocol/openid-connect/auth?client_id=kubernetes&redirect_uri=https%3A%2F%2Fkubernetes-dashboard.example.com%2Foauth%2Fcallback&response_type=code&scope=openid+email+profile&state=94d9198f-3fc9-4712-8f9b-493ea95552e1
date: Fri, 05 Apr 2019 20:25:37 GMT
x-envoy-upstream-service-time: 0
server: istio-envoy
transfer-encoding: chunked

HTTP/1.1 200 OK
cache-control: no-store, must-revalidate, max-age=0
set-cookie: AUTH_SESSION_ID=2563326b-cf25-460e-8821-2b8d16e21b94.keycloak-0; Version=1; Path=/auth/realms/default/; HttpOnly
set-cookie: KC_RESTART=eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI5NzMzNGM3MS1kZTVmLTRhZTItYjlhOC1jZDZiMzRlNTEyYmIifQ.eyJjaWQiOiJrdWJlcm5ldGVzIiwicHR5Ijoib3BlbmlkLWNvbm5lY3QiLCJydXJpIjoiaHR0cHM6Ly9rdWJlcm5ldGVzLWRhc2hib2FyZC53ZWF2ZWxhYi5pby9vYXV0aC9jYWxsYmFjayIsImFjdCI6IkFVVEhFTlRJQ0FURSIsIm5vdGVzIjp7InNjb3BlIjoib3BlbmlkIGVtYWlsIHByb2ZpbGUiLCJpc3MiOiJodHRwczovL3Nzby53ZWF2ZWxhYi5pby9hdXRoL3JlYWxtcy9kZWZhdWx0IiwicmVzcG9uc2VfdHlwZSI6ImNvZGUiLCJjb2RlX2NoYWxsZW5nZV9tZXRob2QiOiJwbGFpbiIsInJlZGlyZWN0X3VyaSI6Imh0dHBzOi8va3ViZXJuZXRlcy1kYXNoYm9hcmQud2VhdmVsYWIuaW8vb2F1dGgvY2FsbGJhY2siLCJzdGF0ZSI6Ijk0ZDkxOThmLTNmYzktNDcxMi04ZjliLTQ5M2VhOTU1NTJlMSJ9fQ.hNJy6xOBQXAHPjmqcvz2Hs_uT04F9NgA3g1iPUFkqH4; Version=1; Path=/auth/realms/default/; HttpOnly
x-xss-protection: 1; mode=block
x-frame-options: SAMEORIGIN
content-security-policy: frame-src 'self'; frame-ancestors 'self'; object-src 'none';
date: Fri, 05 Apr 2019 20:25:38 GMT
x-robots-tag: none
strict-transport-security: max-age=31536000; includeSubDomains
x-content-type-options: nosniff
content-type: text/html;charset=utf-8
content-length: 2949
content-language: en
x-envoy-upstream-service-time: 14
server: istio-envoy
```

Check if Keycloak is running.

```bash
kubectl -n keycloak get pods,svc,pvc -o wide -l app=keycloak-gatekeeper --all-namespaces
```

```text
NAMESPACE     NAME                                                            READY   STATUS    RESTARTS   AGE   IP             NODE     NOMINATED NODE   READINESS GATES
kube-system   pod/kubernetes-dashboard-keycloak-gatekeeper-75474678b6-gv7td   1/1     Running   0          78m   10.2.140.70    node02   <none>           <none>
monitoring    pod/alertmanager-keycloak-gatekeeper-58564fdc76-shv8j           1/1     Running   0          83m   10.2.140.124   node02   <none>           <none>
monitoring    pod/prometheus-keycloak-gatekeeper-6b48d857b7-ct85d             1/1     Running   0          83m   10.2.140.123   node02   <none>           <none>
weave         pod/weave-scope-app-keycloak-gatekeeper-5579fcc9bb-6sxzl        1/1     Running   0          83m   10.2.248.199   node04   <none>           <none>

NAMESPACE     NAME                                               TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE   SELECTOR
kube-system   service/kubernetes-dashboard-keycloak-gatekeeper   ClusterIP   10.3.0.139   <none>        3000/TCP   83m   app=keycloak-gatekeeper,release=kubernetes-dashboard
monitoring    service/alertmanager-keycloak-gatekeeper           ClusterIP   10.3.0.169   <none>        3000/TCP   83m   app=keycloak-gatekeeper,release=alertmanager
monitoring    service/prometheus-keycloak-gatekeeper             ClusterIP   10.3.0.167   <none>        3000/TCP   83m   app=keycloak-gatekeeper,release=prometheus
weave         service/weave-scope-app-keycloak-gatekeeper        ClusterIP   10.3.0.166   <none>        3000/TCP   83m   app=keycloak-gatekeeper,release=weave-scope-app
```