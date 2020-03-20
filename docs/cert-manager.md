# Cert-Manager



Cert-Manager deployment is enabled by the following pillar data.

> Only Cloudflare is supported as dns provider for Let's Encrypt DNS01 challenge.

```yaml
public-domain: domain.tld
kubernetes:
  common:
    addons:
      cert_manager:
        enabled: True
        version: 0.11.0
        acme_email: username@example.com
        dns:
          provider: cloudflare
          email: <Login email>
          secret: <Global API Key>
```

To manually deploy Cert-Manager, run the following command line from the **Salt-Master** (i.e. edge01).

```bash
salt -G role:master state.apply kubernetes.ingress.cert-manager
```
## Troubleshooting

Check if Cert-Manager is running.

```bash
kubectl -n cert-manager get pods
```

```text
NAME                            READY   STATUS    RESTARTS   AGE
cert-manager-546bc6c88f-4f994   1/1     Running   0          3h21m
```

Check if Cert-Manager has delivered the certificate to Istio.

```bash
kubectl -n cert-manager logs -l app=cert-manager
```

```text
I1027 11:48:22.285586       1 issue.go:173] successfully obtained certificate: cn="*.domain.tld" altNames=[*.domain.tld domain.tld] url="https://acme-v02.api.letsencrypt.org/acme/order/12345678/987654321"
I1027 11:48:22.359271       1 sync.go:268] Certificate issued successfully
I1027 11:48:22.385315       1 controller.go:195] certificates controller: Finished processing work item "istio-system/domain-ingress-certs"
```
