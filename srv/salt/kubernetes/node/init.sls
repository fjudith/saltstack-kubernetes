{%- from "kubernetes/map.jinja" import common with context -%}
{%- set os = salt['grains.get']('os') -%}

include:
  - kubernetes/cni
  - kubernetes/cri/{{ common.cri.provider }}
  - kubernetes/cri/rkt
  - kubernetes/node/kubelet
  - kubernetes/node/kube-proxy

{% if os == "Debian" or os == "Ubuntu" %}
glusterfs-client:
  pkg.latest

conntrack:
  pkg.latest

nfs-common:
  pkg.latest
{% endif %} 

open-iscsi:
  pkg.latest

xfsprogs:
  pkg.latest

azure-cli:
  pkg.latest

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

/etc/kubernetes/volumeplugins:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 700

{% if common.cni.calico.ipv6.enable == true %}
net.ipv6.conf.all.forwarding:
  sysctl.present:
    - value: 1
{% endif %}
