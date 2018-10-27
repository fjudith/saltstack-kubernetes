# Containerd

## Updating

The `kubernetes.cri.containerd` does not support update function.
The following procedure allows to udpate containerd on the appropriate salt minions.

```bash
VERSION=1.2.0

salt -G role:proxy cmd.run "curl -L https://github.com/containerd/containerd/releases/download/v${VERSION}/containerd-${VERSION}.linux-amd64.tar.gz | tar -xvzf - -C /usr/local"
salt -G role:proxy cmd.run "systemctl restart containerd && systemctl restart kubelet"

salt -G role:node cmd.run "curl -L https://github.com/containerd/containerd/releases/download/v${VERSION}/containerd-${VERSION}.linux-amd64.tar.gz | tar -xvzf - -C /usr/local"
salt -G role:node cmd.run "systemctl restart containerd && systemctl restart kubelet"

salt -G role:master cmd.run "curl -L https://github.com/containerd/containerd/releases/download/v${VERSION}/containerd-${VERSION}.linux-amd64.tar.gz | tar -xvzf - -C /usr/local"
salt -G role:master cmd.run "systemctl restart containerd && systemctl restart kubelet"
```