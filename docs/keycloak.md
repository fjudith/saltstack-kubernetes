# Keycloak

Keycloak deployment is enabled by the following pillar data.

> _Helm [stable](https://github.com/helm/charts/tree/master/stable/keycloak) chart is leveraged to ensure long-term support._

```yaml
public-domain: domain.tld
kubernetes:
  charts:
    keycloak:
      enabled: True
      ingress_host: sso
```

To manually deploy Keycloak, run the following command line from the **Salt-Master** (i.e. proxy01).

```bash
salt -G role:master state.apply kubernetes.charts.keycloak
```

To retreive the generated `keycloak` admin password, run the following commande line.

```bash
kubectl get secret --namespace keycloak keycloak-http -o jsonpath="{.data.password}" | base64 --decode; echo
```

```text
MQbhAwIt44
```

## Troubleshooting

Check if Keycloak is accessible via the Istio Ingress Gateway.

```bash
curl -IL https://sso.domain.tld
```

```text
HTTP/1.1 200 OK
last-modified: Wed, 15 Aug 2018 11:12:46 GMT
content-length: 1087
content-type: text/html
accept-ranges: bytes
date: Sat, 27 Oct 2018 19:16:39 GMT
x-envoy-upstream-service-time: 9
server: envoy
```

Check if Keycloak is running.

```bash
kubectl -n keycloak get pods,svc,pvc -o wide
```

```text
NAME                                       READY   STATUS    RESTARTS   AGE   IP            NODE     NOMINATED NODE
pod/keycloak-0                             1/1     Running   0          25m   10.2.192.15   node04   <none>
pod/keycloak-1                             1/1     Running   0          25m   10.2.96.15    node03   <none>
pod/keycloak-postgresql-5747fd5677-mwkvp   1/1     Running   0          25m   10.2.80.15    node05   <none>

NAME                          TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE   SELECTOR
service/keycloak-headless     ClusterIP   None         <none>        80/TCP     25m   app=keycloak,release=keycloak
service/keycloak-http         ClusterIP   10.3.0.86    <none>        80/TCP     25m   app=keycloak,release=keycloak
service/keycloak-postgresql   ClusterIP   10.3.0.104   <none>        5432/TCP   25m   app=postgresql,release=keycloak

NAME                                        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS
   AGE
persistentvolumeclaim/keycloak-postgresql   Bound    pvc-ff576849-da19-11e8-8fa7-96000012e4d1   8Gi        RWO            rook-ceph-block
```