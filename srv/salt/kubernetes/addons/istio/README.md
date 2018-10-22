# Istio

[Istio](https://istio.io) is a Service Mesh and Ingress Gateway built on Envoy which allows to connect, secure, control and observe services.

### Customization

The Kubernetes cluster architecture deployed involves dedicated nodes for the ingress traffic.
Therefore [default Istio installation manifest](https://github.com/istio/istio/tree/master/install/kubernetes) is modified to get two `istio-ingressgateway` and `istio-egressgateway` on Nodes with label an toleration `node-role.kubernetes.io/ingress` (e.g. proxy01, proxy02).


### istio-ingressgateway & istio-egressgateway

Update the `istio-demo.yaml` and update the following records in order to get pods scheduled on nodes with taint and toleration `node-role.kubernetes.io/ingress`.

```yaml
spec:
  replicas: 2
...
    spec:
      tolerations:
        - key: node-role.kubernetes.io/ingress
          effect: NoSchedule
      nodeSelector:
        node-role.kubernetes.io/ingress: "true"
```

### istio-ingressgateway only

Add the following data to `istio-ingressgateway` deployment in order to export http and https ports.

```yaml
...
            - containerPort: 80
              hostPort: 80
              protocol: TCP
            - containerPort: 443
              hostPort: 443
              protocol: TCP
```