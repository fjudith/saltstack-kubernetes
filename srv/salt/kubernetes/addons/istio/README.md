# Istio

[Istio](https://istio.io) is a Service Mesh and Ingress Gateway built on Envoy which allows to connect, secure, control and observe services.

### Customization

The Kubernetes cluster architecture deployed involves dedicated nodes for the ingress traffic.
Therefore [default Istio installation manifest](https://github.com/istio/istio/tree/master/install/kubernetes) si modified to get the `istio-ingressgateway` deployed as a [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) on Nodes with labeled with the Ingress Role (e.g. proxy01, proxy02).

