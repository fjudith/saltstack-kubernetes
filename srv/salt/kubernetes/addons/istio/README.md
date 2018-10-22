# Istio

[Istio](https://istio.io) is a Service Mesh and Ingress Gateway built on Envoy which allows to connect, secure, control and observe services.

### Customization

The Kubernetes cluster architecture deployed involves dedicated nodes for the ingress traffic.
Therefore [default Istio installation manifest](https://github.com/istio/istio/tree/master/install/kubernetes) is modified to get two `istio-ingressgateway` and `istio-egressgateway` on Nodes with label an toleration `node-role.kubernetes.io/ingress` (e.g. proxy01, proxy02).

```yaml
spec:
  replicas: 2
    spec:
      tolerations:
        - key: node-role.kubernetes.io/ingress
          effect: NoSchedule
      nodeSelector:
        node-role.kubernetes.io/ingress: "true"
```