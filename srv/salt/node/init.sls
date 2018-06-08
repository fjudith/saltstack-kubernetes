{%- set k8sVersion = pillar['kubernetes']['version'] -%}
{%- set os = salt['grains.get']('os') -%}
{%- set enableIPv6 = pillar['kubernetes']['node']['networking']['calico']['ipv6']['enable'] -%}
{%- set criProvider = pillar['kubernetes']['node']['runtime']['provider'] -%}

include:
  - node/cri/{{ criProvider }}
  - node/cni
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

vm.max_map_count:
  sysctl.present:
    - value: 2097152

/usr/bin/kubelet:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8sVersion }}/bin/linux/amd64/kubelet
    - skip_verify: true
    - group: root
    - mode: 755

/usr/bin/kube-proxy:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8sVersion }}/bin/linux/amd64/kube-proxy
    - skip_verify: true
    - group: root
    - mode: 755

/var/lib/kubelet:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 700

/etc/kubernetes/kubeconfig:
    file.managed:
    - source: salt://node/kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/systemd/system/kubelet.service:
    file.managed:
    - source: salt://node/kubelet.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/kube-proxy.kubeconfig:
    file.managed:
    - source: salt://node/kube-proxy.kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/systemd/system/kube-proxy.service:
  file.managed:
    - source: salt://node/kube-proxy.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubelet:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - /etc/systemd/system/kubelet.service

kube-proxy:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - /etc/systemd/system/kube-proxy.service

{% if enableIPv6 == true %}
net.ipv6.conf.all.forwarding:
  sysctl.present:
    - value: 1
{% endif %}
