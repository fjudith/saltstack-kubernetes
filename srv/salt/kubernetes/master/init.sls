{%- from "kubernetes/map.jinja" import etcd with context -%}
{%- from "kubernetes/map.jinja" import common with context -%}

{%- set ipv4Range = pillar['kubernetes']['node']['networking']['flannel']['ipv4']['range'] -%}
{%- set cni_provider = pillar['kubernetes']['node']['networking']['provider'] -%}

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
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ common.version }}/bin/linux/amd64/kubectl
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

{% if cni_provider == "calico" %}

/srv/kubernetes/calico.yaml:
    file.managed:
    - source: salt://kubernetes/cni/calico/calico.tmpl.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

{% elif cni_provider == "flannel" %}

/etc/kubernetes/ssl/node.pem:
  file.symlink:
    - target: /etc/kubernetes/ssl/master.pem

/etc/kubernetes/ssl/node-key.pem:
  file.symlink:
    - target: /etc/kubernetes/ssl/master-key.pem

/etc/kubernetes/manifests/flannel.yaml:
    file.managed:
    - source: salt://kubernetes/cni/flannel/flannel.yaml
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
      - ACTIVE_ETCD: https://{{ etcd.members[0].host }}:2379
    - name: |
        curl --cacert /etc/kubernetes/ssl/ca.pem --key /etc/kubernetes/ssl/master-key.pem --cert /etc/kubernetes/ssl/master.pem --silent -X PUT -d "value={\"Network\":\"{{ ipv4Range }}\",\"Backend\":{\"Type\":\"vxlan\"}}" "https://{{ etcd.members[0].host }}:2379/v2/keys/coreos.com/network/config?prevExist=false"

query-fannel-required-api:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:8080/apis/extensions/v1beta1/daemonsets'
    - wait_for: 900
    - request_interval: 5
    - status: 200

flannel-install:
  cmd.run:
    - require:
      - cmd: flannel-etcd-config
      - http: query-fannel-required-api
    - watch:
      - file: /etc/kubernetes/manifests/flannel.yaml
    - runas: root
    - name: kubectl apply -f /etc/kubernetes/manifests/flannel.yaml

{% elif cni_provider == "weave" %}

/etc/kubernetes/manifests/weave.yaml:
    file.managed:
    - source: salt://kubernetes/cni/weave/weave.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

query-weave-required-api:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:8080/apis/extensions/v1beta1/daemonsets'
    - wait_for: 900
    - request_interval: 5
    - status: 200

weave-install:
  cmd.run:
    - require:
      - http: query-weave-required-api
    - watch:
      - file: /etc/kubernetes/manifests/weave.yaml
    - runas: root
    - name: kubectl apply -f /etc/kubernetes/manifests/weave.yaml

{% endif %}
