{%- set k8sVersion = pillar['kubernetes']['version'] -%}
{%- set os = salt['grains.get']('os') -%}
{%- set enableIPv6 = pillar['kubernetes']['node']['networking']['calico']['ipv6']['enable'] -%}
{%- set criProvider = pillar['kubernetes']['node']['runtime']['provider'] -%}

include:
  - kubernetes/cri/{{ criProvider }}
  - kubernetes/cri/rkt
  - kubernetes/cni

{% if os == "Debian" or os == "Ubuntu" %}
glusterfs-client:
  pkg.latest

conntrack:
  pkg.latest

nfs-common:
  pkg.latest
{% endif %} 

socat:
  pkg.latest

bridge-utils:
  pkg.latest

vm.max_map_count:
  sysctl.present:
    - value: 2097152

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

/usr/lib/coreos/kubelet-wrapper:
  file.managed:
    - source: salt://node/kubelet/kubelet-wrapper
    - user: root
    - template: jinja
    - group: root
    - mode: 755

/etc/systemd/system/kubelet.service:
    file.managed:
    - source: salt://node/kubelet/kubelet.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/kubelet.kubeconfig:
    file.managed:
    - source: salt://node/kubelet/kubelet.kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/bootstrap.kubeconfig:
    file.managed:
    - source: salt://node/kubelet/bootstrap.kubeconfig
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
    - source: salt://node/kube-proxy/kube-proxy.kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/manifests/kube-proxy.yaml:
    file.managed:
    - source: salt://node/kube-proxy/kube-proxy.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/volumeplugins:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 700

{% if enableIPv6 == true %}
net.ipv6.conf.all.forwarding:
  sysctl.present:
    - value: 1
{% endif %}
