# Mailhog

Mailhog deployment is enabled by the following pillar data.

> _Helm [stable](https://github.com/helm/charts/tree/master/stable/mailhog) chart is leveraged to ensure long-term support._

```yaml
public-domain: domain.tld
kubernetes:
  charts:
    mailhog:
      enabled: True
    ingress_host: mail
```

To manually deploy Mailhog, run the following command line from the **Salt-Master** (i.e. edge01).

```bash
salt -G role:master state.apply kubernetes.charts.mailhog
```

## Troubleshooting

Check if Mailhog is accessible via the Istio Ingress Gateway.

>_[httpie](https://httpie.org/doc#installation) is required to query the Mailhog webui._
>_It does not work with cURL due to Jquery source code._

```bash
http --heades https://mailhog.domain.tld
```

```text
HTTP/1.1 200 OK
content-type: text/html; charset=utf-8
date: Sat, 27 Oct 2018 20:05:53 GMT
server: envoy
transfer-encoding: chunked
x-envoy-upstream-service-time: 10
```

Check if Mailhog is running.

```bash
kubectl -n mailhog get pods,svc -o wide
```

```text
NAME                           READY   STATUS    RESTARTS   AGE   IP           NODE     NOMINATED NODE
pod/mailhog-74fc497475-6zshs   1/1     Running   0          34m   10.2.240.8   node02   <none>

NAME              TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)             AGE   SELECTOR
service/mailhog   ClusterIP   10.3.0.43    <none>        8025/TCP,1025/TCP   34m   app=mailhog,release=mailhog
```