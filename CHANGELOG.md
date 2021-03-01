# Change Log

## Unreleased

* Kubernetes: Enforcing strict Pod Security Policy

## v7.1.0 - 2021-03-01

## Added

* MailHog: Enabled support of user credentials list

## Changed

* MailHog: Bump version 1.0.1
* Ory Kratos: Migrated Selfservice UI deployment to Helm chart
* Rook-CockroachDB: Bump version 1.5.8
* Rook-YugabyteDB: Bump version 1.5.8

## Fixed


* Ory Hydra: Fixed  hydra binary download
* Ory Kratos: Migration to v0.5 config spec
* Harbor: Use v2.0 Api for the OIDC configuration

## v7.0.0 - 2021-02-28

### Added

* Added Open Policy Agent support
  Bump version 3.3.0
  Whitelisting image registries
  Enforce resource labels
  Enforce unique ingress hosts

### Changed

* **General**: Use of secure port to determine Kubernetes API resources readiness due to removal of `--insecure-port` argument in k8s 1.20.0
* Salt: Bump version 3002.5
  * Migrated to the new official https://saltproject.io repository
* Envoy: Bump version 1.17.1
  * Migrated configuration to Envoy v3 API
* Kubernetes: Bump version 1.20.4
  * Enabled PodSecurityPolicy admission controller
* Calico: Bump version 3.18.0
* CodeDNS: Dowgraded version from 1.7.0 to 1.6.5
* Kubernetes Dashboard: Bump version 2.2.0
* Metrics Server: Bump version 0.4.2
  * Now use appropriate kubelet secure port
  * Updated preffered_address priorisation
* Cert-Manager: Bump version 1.1.1
* Contour: Bump version 1.13.0
  * Leverage Envoy proxy 1.17.1
* Kube-Prometheus: Enabled state for Grafana password configuration
* Kubeless: Bump version 1.0.8
* Helm: Bump version 3.5.2
* NATS: Bump versions
  * NATS operator: Bump version 0.7.4
  * NATS streaming operator: Bump version 0.4.2
  * NATS server: Bump version 2.1.9
  * NATS streaming server: Bump version 0.20.0
* Node-Problem-Detector: Bump version 0.8.7
* Istio: Bump version 1.9.0
* Argo: Bump version 2.12.2
* Argo Events: Bump version 1.2.3
* Argo CD: Bump version 1.18.6
* Concourse: Bump version 7.0.0
  * Enabled containerd support for workers
* Concourse: Bump version 7.0.0
  * Enabled containerd support for workers
* Falco: Bump version 0.27.0
* Fission: Bump version 1.12.0
* Gitea: Bump version 1.13.2
* Harbor: Bump version 2.2.0
* Keycloak: Bump version 12.0.3
* Nuclio: Bump version 1.6.1
* OpenFaaS: Bump version 0.13.1
  * Removed dependency shared NATS/STAN operator managed cluster
  * Leverage dedicated NAT Streaming server
* Ory Hydra: Bump version 1.9.2
* Ory Kratos: Bump version 0.5.5
* Ory Oathkeeper: Bump version 0.38.6
* Spinnaker: Bump version 1.25.0
  * Leverage Halyard version 1.41.0
* Velero: Bump version 1.5.3
* Rook-Ceph: Bump version 1.5.8
  * Run Ceph version 15.2.9


### Fixed

* Metrics-Server: use `--kubelet-insecure-tls`
  kubeadm does not generate IP/SANS for kubelet certificates
* CoreDNS: Store manifests in dedicated `coredns` directory
* Argo CD: Fixed compatiblity with Contour ingress controller
* Falco: Changed Helm upgrade timeout from 5m to 10m
* OpenFaaS: Removed Istio injection conflicting with NATS Streaming