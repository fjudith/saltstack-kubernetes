# Kubeless

Kubeless deployment is enabled by the following pillar data.

```yaml
public-domain: domain.tld
kubernetes:
  common:
    addons:
      kubeless:
        enabled: True
        version: 1.0.0
        ui_version: master
```

To manually deploy Kubeless, run the following command line from the **Salt-Master** (i.e. proxy01).

```bash
salt -G role:master state.apply kubernetes.addons.kubeless
```

## Troubleshooting

Check if Keycloak is accessible via the Istio Ingress Gateway.

```bash
curl -IL https://kubeless.domain.tld
```

```text
HTTP/2 200
x-powered-by: Express
accept-ranges: bytes
cache-control: public, max-age=0
last-modified: Mon, 27 Aug 2018 07:29:13 GMT
etag: W/"3ce-1657a495d28"
content-type: text/html; charset=UTF-8
content-length: 974
vary: Accept-Encoding
date: Sun, 11 Nov 2018 00:45:24 GMT
x-envoy-upstream-service-time: 15
server: envoy
```

Check if Kubeless is running.

```bash
kubectl -n kubeless get pods,svc,pvc -o wide
```

```text
AME                                              READY   STATUS    RESTARTS   AGE    IP           NODE
     NOMINATED NODE
pod/kubeless-controller-manager-9778cb7bd-nc8fp   3/3     Running   0          3d4h   10.2.96.2    node03   <none>
pod/ui-84cf74cd9c-7tp6k                           2/2     Running   2          14d    10.2.192.2   node04   <none>

NAME         TYPE       CLUSTER-IP   EXTERNAL-IP   PORT(S)          AGE   SELECTOR
service/ui   NodePort   10.3.0.218   <none>        3000:46191/TCP   14d   controller=ui
```