{%- set k8sVersion = pillar['kubernetes']['version'] -%}
{%- set os = salt['grains.get']('os') -%}
{%- set enableIPv6 = pillar['kubernetes']['node']['networking']['calico']['ipv6']['enable'] -%}
{%- set criProvider = pillar['kubernetes']['node']['runtime']['provider'] -%}

include:
  - node/cri/{{ criProvider }}
  - node/cni
  - node/cri/rkt
  
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

/opt/bin:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

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
    - source: salt://node/kubelet-wrapper
    - user: root
    - template: jinja
    - group: root
    - mode: 755

/etc/systemd/system/kubelet.service:
    file.managed:
    - source: salt://node/kubelet.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/kubelet.kubeconfig:
    file.managed:
    - source: salt://node/kubelet.kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/bootstrap.kubeconfig:
    file.managed:
    - source: salt://node/bootstrap.kubeconfig
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
    - source: salt://node/kube-proxy.kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/manifests/kube-proxy.yaml:
    file.managed:
    - source: salt://node/kube-proxy.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

{# /usr/bin/kubelet:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8sVersion }}/bin/linux/amd64/kubelet
    - skip_verify: true
    - show_changes: False
    - group: root
    - mode: 755

/usr/bin/kube-proxy:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8sVersion }}/bin/linux/amd64/kube-proxy
    - skip_verify: true
    - show_changes: False
    - group: root
    - mode: 755 #}

/etc/kubernetes/volumeplugins:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 700

{# /var/lib/kubelet:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 700 #}

{# /etc/kubernetes/kubeconfig:
    file.managed:
    - source: salt://node/kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 644 #}

{# /etc/systemd/system/kubelet.service:
    file.managed:
    - source: salt://node/kubelet.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644 #}

{# /etc/kubernetes/kube-proxy.kubeconfig:
    file.managed:
    - source: salt://node/kube-proxy.kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 644 #}

{# /etc/systemd/system/kube-proxy.service:
  file.managed:
    - source: salt://node/kube-proxy.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644 #}

{# kubelet:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/kubelet.service
      - /usr/bin/kubelet #}

{# kube-proxy:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/kube-proxy.service
      - /usr/bin/kube-proxy #}

{% if enableIPv6 == true %}
net.ipv6.conf.all.forwarding:
  sysctl.present:
    - value: 1
{% endif %}
