{%- set k8sVersion = pillar['kubernetes']['binary-version'] -%}
{%- set hyperkubeImageRepo = pillar['kubernetes']['hyperkube-image-repo'] -%}
{%- set hyperkubeVersion = pillar['kubernetes']['version'] -%}
{%- set masterCount = pillar['kubernetes']['master']['count'] -%}
{%- set etcd01ip =  pillar['kubernetes']['etcd']['cluster']['etcd01']['ipaddr'] -%} 
{%- set etcd02ip =  pillar['kubernetes']['etcd']['cluster']['etcd02']['ipaddr'] -%} 
{%- set etcd03ip =  pillar['kubernetes']['etcd']['cluster']['etcd03']['ipaddr'] -%}
{%- set ipv4Range = pillar['kubernetes']['node']['networking']['flannel']['ipv4']['range'] -%}

{# include:
  - etcd #}

include:
  - kubernetes.cri.docker
  - kubernetes.cri.rkt
  - kubernetes.cni

conntrack:
  pkg.latest
  
bridge-utils:
  pkg.latest

net.ipv4.ip_forward:
  sysctl.present:
    - value: 1

net.ipv6.conf.all.forwarding:
  sysctl.present:
    - value: 1

net.bridge.bridge-nf-call-arptables:
  sysctl.present:
    - value: 1

net.bridge.bridge-nf-call-ip6tables:
  sysctl.present:
    - value: 1

net.bridge.bridge-nf-call-iptables:
  sysctl.present:
    - value: 1

net.bridge.bridge-nf-filter-pppoe-tagged:
  sysctl.present:
    - value: 0

net.bridge.bridge-nf-filter-vlan-tagged:
  sysctl.present:
    - value: 0

net.bridge.bridge-nf-pass-vlan-input-dev:
  sysctl.present:
    - value: 0

/usr/sbin/modprobe:
  file.symlink:
    - target: /sbin/modprobe

/etc/kubernetes/manifests:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/usr/lib/coreos:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/var/lib/coreos:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/usr/bin/mkdir:
  file.symlink:
    - target: /bin/mkdir

/usr/bin/bash:
  file.symlink:
    - target: /bin/bash

/usr/bin/kubectl:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8sVersion }}/bin/linux/amd64/kubectl
    - skip_verify: true
    - show_changes: False
    - group: root
    - mode: 755

/usr/lib/coreos/kubelet-wrapper:
  file.managed:
    - source: salt://kubernetes/master/kubelet/kubelet-wrapper
    - user: root
    - template: jinja
    - group: root
    - mode: 755

/etc/systemd/system/kubelet.service:
    file.managed:
    - source: salt://kubernetes/master/kubelet/kubelet.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/kubelet.kubeconfig:
    file.managed:
    - source: salt://kubernetes/master/kubelet/kubelet.kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/bootstrap.kubeconfig:
    file.managed:
    - source: salt://kubernetes/master/kubelet/bootstrap.kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubelet:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/kubelet.service
      - /etc/kubernetes/kubelet.kubeconfig

/etc/kubernetes/kube-proxy.kubeconfig:
    file.managed:
    - source: salt://kubernetes/master/kube-proxy/kube-proxy.kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/manifests/kube-proxy.yaml:
    file.managed:
    - source: salt://kubernetes/master/kube-proxy/kube-proxy.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/manifests/kube-apiserver.yaml:
    file.managed:
    - source: salt://kubernetes/master/kube-apiserver/kube-apiserver.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/kube-controller-manager.kubeconfig:
    file.managed:
    - source: salt://kubernetes/master/kube-controller-manager/kube-controller-manager.kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/kube-scheduler.kubeconfig:
    file.managed:
    - source: salt://kubernetes/master/kube-scheduler/kube-scheduler.kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/kube-scheduler-config.yaml:
    file.managed:
    - source: salt://kubernetes/master/kube-scheduler/kube-scheduler-config.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/manifests/kube-controller-manager.yaml:
    file.managed:
    - source: salt://kubernetes/master/kube-controller-manager/kube-controller-manager.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/manifests/kube-scheduler.yaml:
    file.managed:
    - source: salt://kubernetes/master/kube-scheduler/kube-scheduler.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/audit-policy.yaml:    
    file.managed:
    - source: salt://kubernetes/master/audit-policy.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/encryption-config.yaml:    
    file.managed:
    - source: salt://kubernetes/master/encryption-config.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

{%- set cniProvider = pillar['kubernetes']['node']['networking']['provider'] -%}
{% if cniProvider == "calico" %}

/srv/kubernetes/calico.yaml:
    file.managed:
    - source: salt://node/cni/calico/calico.tmpl.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

{% elif cniProvider == "flannel" %}

/etc/kubernetes/ssl/node.pem:
  file.symlink:
    - target: /etc/kubernetes/ssl/master.pem

/etc/kubernetes/ssl/node-key.pem:
  file.symlink:
    - target: /etc/kubernetes/ssl/master-key.pem

/etc/kubernetes/manifests/flannel.yaml:
    file.managed:
    - source: salt://node/cni/flannel/flannel.tmpl.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

flannel-etcd-config:
  cmd.run:
    - require:
      - file: /etc/kubernetes/manifests/flannel.yaml
    - runas: root
    - env:
      - ACTIVE_ETCD: https://{{ etcd01ip }}:2379
    - name: |
        curl --cacert /etc/kubernetes/ssl/ca.pem --key /etc/kubernetes/ssl/master-key.pem --cert /etc/kubernetes/ssl/master.pem --silent -X PUT -d "value={\"Network\":\"{{ ipv4Range }}\",\"Backend\":{\"Type\":\"vxlan\"}}" "https://{{ etcd01ip }}:2379/v2/keys/coreos.com/network/config?prevExist=false"

flannel-wait:
  cmd.run:
    - require:
      - cmd: flannel-etcd-config
    - runas: root
    - name: until curl --silent "http://127.0.0.1:8080/apis/extensions/v1beta1" | grep daemonset; do printf 'Kubernetes API and extension not ready to deploy Flannel' && sleep 5; done
    - use_vt: True
    - timeout: 900

flannel-install:
  cmd.run:
    - require:
      - cmd: flannel-etcd-config
      - cmd: flannel-wait
    - watch:
      - file: /etc/kubernetes/manifests/flannel.yaml
    - runas: root
    - name: kubectl apply -f /etc/kubernetes/manifests/flannel.yaml

  
{% endif %}
