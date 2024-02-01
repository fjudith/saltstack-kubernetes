# Saltstack-Kubernetes hack guideLines

This document describes how you can use the scripts from [`hack`](.) directory
and gives a brief introduction and explanation of these scripts.

## Overview

The [`hack`](.) directory contains many scripts that ensure continuous development of the project,
enhance the robustness of the code, improve development efficiency, etc.
The explanations and descriptions of these scripts are helpful for contributors.
For details, refer to the following guidelines.

## Key scripts

* [`hack/provision.sh`](provision.sh): This script is a wrapper related to infrastructure provisionning equivalent to `terraform init/plan/apply`.
* [`hack/release.sh`](release.sh): This script synchronized the Salt configuration files to the salt-master/edge server.
* [`hack/kubeconfig.sh`](kubeconfig.sh): This script download the Kubernetes client configuration file to the `~/.kube/config` directory.
* [`hack/terminate.sh`](terminate.sh): This script is a wrapper related to infrastructure termination equivalent to `terraform destroy`.

## Attention

Note that all scripts must be run from the project **root directory**.
