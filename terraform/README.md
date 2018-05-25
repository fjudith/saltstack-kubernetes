# Terraform Scaleway

The following Terraform asset deploys the following component to the Scaleway cloud.

Name | Quantity | Description | Configuration
---- | -------- | ----------- | -------------
etcd  | 3        | Etcd key/value store cluster | **1-XS**: 1 CPU x86-64, 1 GB RAM, 25 GB disk
proxy | 2        | Reverse-proxy failover cluster | **1-XS**: 1 CPU x86-64, 1 GB RAM, 25 GB disk
master | 3       | Kubernetes master cluster | **1-S**: 2 CPU x86-64, 2 GB RAM, 50 GB disk
Node | 3       | Kubernetes node cluster | **1-M**: 4 CPU x86-64, 4 GB RAM, 100 GB disk

**Cost/Month**: 46€

```bash
export SCALEWAY_TOKEN=<access_key>
export SCALEWAY_ORGANIZATION=<organization-key>

terraform init
terraform plan
terraform apply
terraform show
```