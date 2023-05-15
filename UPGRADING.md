## Kuberbernetes upgrade procedure

The following procedure has been successfully tested for bugfix releases ugprade only.
Please refer to the kubeadm [upgrade documentation](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/) for minor and major upgrades.

```bash
VERSION="1.26.4"

# Install new Kubeadm package on all control-plane nodes
salt -G role:master cmd.run "apt-mark unhold kubeadm && apt-get update && apt-get install -y kubeadm=${VERSION}-00 --allow-downgrades && apt-mark hold kubeadm"
salt -G role:master cmd.run "kubeadm version"

# Upgrade master01 control-plane (init) first 
salt master01 cmd.run "kubeadm upgrade plan"
salt master01 cmd.run "kubectl drain master01 --ignore-daemonsets"
salt master01 cmd.run "sudo kubeadm upgrade apply v${VERSION} --ignore-preflight-errors=all -y -v5"
salt master01 cmd.run "kubectl uncordon master01"

# Upgrade master02 control-plane (join) 
salt master02 cmd.run "kubeadm upgrade plan"
salt master02 cmd.run "kubectl drain master02 --ignore-daemonsets"
salt master02 cmd.run "sudo kubeadm upgrade node -v5"
salt master02 cmd.run "kubectl uncordon master02"

# Upgrade master03 control-plane (join) 
salt master03 cmd.run "kubeadm upgrade plan"
salt master03 cmd.run "kubectl drain master03 --ignore-daemonsets"
salt master03 cmd.run "sudo kubeadm upgrade node -v5"
salt master03 cmd.run "kubectl uncordon master03"

# Upgrade control-plane node components
salt -G role:master cmd.run "apt-mark unhold kubelet kubectl && apt-get update && apt-get install -y kubelet=${VERSION}-00 kubectl=${VERSION}-00 && apt-mark hold kubelet kubectl"
salt -G role:master cmd.run "sudo systemctl daemon-reload && sudo systemctl restart kubelet"

# Upgrade edge node components
salt -G role:edge cmd.run "apt-mark unhold kubelet kubectl && apt-get update && apt-get install -y kubelet=${VERSION}-00 kubectl=${VERSION}-00 && apt-mark hold kubelet kubectl"
salt -G role:edge cmd.run "sudo systemctl daemon-reload && sudo systemctl restart kubelet"

# Upgrade node components
salt -G role:node --batch '1' cmd.run "apt-mark unhold kubelet kubectl && apt-get update && apt-get install -y kubelet=${VERSION}-00 kubectl=${VERSION}-00 && apt-mark hold kubelet kubectl"
salt -G role:node --batch '1'  cmd.run "sudo systemctl daemon-reload && sudo systemctl restart kubelet"
```
