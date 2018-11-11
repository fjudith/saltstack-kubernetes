# HttpBin

HttBin deployment is enabled by the following pillar data.

```yaml
public-domain: domain.tld
kubernetes:
  common:
    addons:
      httpbin:
        enabled: True
```

To manually deploy HttpBin, run the following command line from the **Salt-Master** (i.e. proxy01).

```bash
salt -G role:master state.apply kubernetes.addons.httpbin
```

## Troubleshooting

Check if HttpBin is accessible via the Istio Ingress Gateway.

```bash
curl -IL https://httpbin.domain.tld
```

```text
HTTP/2 200
server: envoy
date: Sun, 11 Nov 2018 00:52:37 GMT
content-type: text/html; charset=utf-8
content-length: 11602
access-control-allow-origin: *
access-control-allow-credentials: true
x-envoy-upstream-service-time: 21
```

Check if HttpBin is running.

```bash
kubectl -n default get pods,svc,pvc -o wide -L app=httpbin
```

```text
NAME                           READY   STATUS    RESTARTS   AGE   IP         NODE     NOMINATED NODE
APP=HTTPBIN
pod/httpbin-5765746fb8-kf9th   1/1     Running   1          14d   10.2.0.8   node06   <none>

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE   SELECTOR      APP=HTTPBIN service/httpbin      ClusterIP   10.3.0.83    <none>        8000/TCP   14d   app=httpbin
service/kubernetes   ClusterIP   10.3.0.1     <none>        443/TCP    14d   <none>
```