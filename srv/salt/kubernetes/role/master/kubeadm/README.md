# kubeadm

This state generates the appriopriate kubeadm configuration files.
It is to designed to scrape the various ip adresses and hostnames from [salt mines](https://docs.saltstack.com/en/latest/topics/mine/) deployed on the following system roles.

* etcd
* master

The kubeadm template is based on the full configuration examples:

* [kubeadm](https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2)
* [kubelet](https://godoc.org/k8s.io/kube-proxy/config/v1alpha1#KubeProxyConfiguration)


## References

* [Cgroup driver](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#configure-cgroup-driver-used-by-kubelet-on-control-plane-node)
