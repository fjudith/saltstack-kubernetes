# Vistio

Vistio deployment is enabled by the following pillar data.

> _Helm [stable](https://github.com/nmnellis/vistio/tree/master/helm/vistio) chart is leveraged to ensure long-term support._

```yaml
public-domain: domain.tld
kubernetes:
  charts:
    vistio:
      enabled: True
      version: 0.1.3
      ingress_host: vistio
```

To manually deploy Vistio, run the following command line from the **Salt-Master** (i.e. edge01).

```bash
salt -G role:master state.apply kubernetes.charts.vistio
```

## Troubleshooting

Check if Keycloak is accessible via the Istio Ingress Gateway.

```bash
curl -IL https://vistio.domain.tld
```

```text
HTTP/1.1 200 OK
x-powered-by: Express
accept-ranges: bytes
cache-control: public, max-age=0
last-modified: Thu, 29 Nov 2018 17:53:59 GMT
etag: W/"3ee-167609b2693"
content-type: text/html; charset=UTF-8
content-length: 1006
date: Thu, 29 Nov 2018 22:09:23 GMT
x-envoy-upstream-service-time: 34
server: envoy
```

Check if Vistio is running.

```bash
kubectl -n default get pods,svc,pvc -l app=vistio-api,app=vistio-api -o wide
```

```text
NAME               READY   STATUS    RESTARTS   AGE     IP           NODE     NOMINATED NODE
pod/vistio-api-0   2/2     Running   0          4h17m   10.2.240.6   node03   <none>

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE     SELECTOR
service/vistio-api   ClusterIP   10.3.0.150   <none>        9091/TCP   4h17m   app=vistio-api,release=vistio

NAME                                           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
persistentvolumeclaim/vistio-db-vistio-api-0   Bound    pvc-b220c7ea-f3ff-11e8-9102-960000143fe3   5Gi        RWO            rook-ceph-block   4h17m
```