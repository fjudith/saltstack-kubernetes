{%- from "kubernetes/map.jinja" import common with context -%}

{# include:
  - etcd #}

include:
  - kubernetes.cni
  - kubernetes.cri
  - kubernetes.cri.{{ common.cri.provider }}
  - kubernetes.master.kubelet
  - kubernetes.master.kube-proxy
  - kubernetes.master.kube-apiserver
  - kubernetes.master.kube-controller-manager
  - kubernetes.master.kube-scheduler
  - kubernetes.cni.{{ common.cni.provider }}

conntrack:
  pkg.latest
  
bridge-utils:
  pkg.latest

socat:
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

/etc/kubernetes/ssl/node.pem:
  file.symlink:
    - target: /etc/kubernetes/ssl/master.pem

/etc/kubernetes/ssl/node-key.pem:
  file.symlink:
    - target: /etc/kubernetes/ssl/master-key.pem