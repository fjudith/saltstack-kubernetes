{%- set k8sVersion = pillar['kubernetes']['binary-version'] -%}
{%- set hyperkubeImageRepo = pillar['kubernetes']['hyperkube-image-repo'] -%}
{%- set hyperkubeVersion = pillar['kubernetes']['version'] -%}
{%- set masterCount = pillar['kubernetes']['master']['count'] -%}
{%- set etcd01ip =  pillar['kubernetes']['etcd']['cluster']['etcd01']['ipaddr'] -%} 
{%- set etcd02ip =  pillar['kubernetes']['etcd']['cluster']['etcd02']['ipaddr'] -%} 
{%- set etcd03ip =  pillar['kubernetes']['etcd']['cluster']['etcd03']['ipaddr'] -%}
{%- set ipv4Range = pillar['kubernetes']['node']['networking']['flannel']['ipv4']['range'] -%}

{# include:
  - master/etcd #}

include:
  - node.cri.docker
  - node.cri.rkt
  - node/cni
  - kubernetes

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
    - source: salt://master/kubelet-wrapper
    - user: root
    - template: jinja
    - group: root
    - mode: 755

/etc/systemd/system/kubelet.service:
    file.managed:
    - source: salt://master/kubelet.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/kubelet.kubeconfig:
    file.managed:
    - source: salt://master/kubelet.kubeconfig
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

/opt/bin/host-rkt:
    file.managed:
    - source: salt://master/host-rkt
    - user: root
    - template: jinja
    - group: root
    - mode: 755


/etc/systemd/system/load-rkt-stage1.service:
    file.managed:
    - source: salt://master/load-rkt-stage1.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

load-rkt-stage1:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/load-rkt-stage1.service

/etc/systemd/system/rkt-api.service:
    file.managed:
    - source: salt://master/rkt-api.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

rkt-api:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/rkt-api.service

/etc/kubernetes/kube-proxy.kubeconfig:
    file.managed:
    - source: salt://master/kube-proxy.kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/manifests/kube-proxy.yaml:
    file.managed:
    - source: salt://master/kube-proxy.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/manifests/kube-apiserver.yaml:
    file.managed:
    - source: salt://master/kube-apiserver.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/manifests/kube-controller-manager.yaml:
    file.managed:
    - source: salt://master/kube-controller-manager.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/manifests/kube-scheduler.yaml:
    file.managed:
    - source: salt://master/kube-scheduler.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

{# /usr/bin/kube-apiserver:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8sVersion }}/bin/linux/amd64/kube-apiserver
    - skip_verify: true
    - show_changes: False
    - group: root
    - mode: 755 #}

{# /usr/bin/kube-controller-manager:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8sVersion }}/bin/linux/amd64/kube-controller-manager
    - skip_verify: true
    - show_changes: False
    - group: root
    - mode: 755 #}

{# /usr/bin/kube-scheduler:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8sVersion }}/bin/linux/amd64/kube-scheduler
    - skip_verify: true
    - show_changes: False
    - group: root
    - mode: 755 #}

/usr/bin/kubectl:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8sVersion }}/bin/linux/amd64/kubectl
    - skip_verify: true
    - show_changes: False
    - group: root
    - mode: 755

{# {% if masterCount == 1 %}
/etc/systemd/system/kube-apiserver.service:
    file.managed:
    - source: salt://master/kube-apiserver.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644
{% elif masterCount == 3 %}
/etc/systemd/system/kube-apiserver.service:
    file.managed:
    - source: salt://master/kube-apiserver-ha.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644
{% endif %} #}

{# /etc/systemd/system/kube-controller-manager.service:
  file.managed:
    - source: salt://master/kube-controller-manager.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644 #}

{# /etc/systemd/system/kube-scheduler.service:
  file.managed:
    - source: salt://master/kube-scheduler.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644 #}

/etc/kubernetes/audit-policy.yaml:    
    file.managed:
    - source: salt://master/audit-policy.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/encryption-config.yaml:    
    file.managed:
    - source: salt://master/encryption-config.yaml
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
  http.wait_for_successful_query:
    - name: http://127.0.0.1:8080/version/
    - request_interval: 5
    - wait_for: 300
    - status: 200
    - require:
      - cmd: flannel-etcd-config

  
{% endif %}


{# kube-apiserver:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - /etc/systemd/system/kube-apiserver.service
      #- /etc/kubernetes/ssl/apiserver.pem #}

{# kube-controller-manager:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - /etc/systemd/system/kube-controller-manager.service
      #- /etc/kubernetes/ssl/apiserver.pem #}

{# kube-scheduler:
  service.running:
   - enable: True
   - reload: True
   - watch:
     - /etc/systemd/system/kube-scheduler.service
     #- /etc/kubernetes/ssl/apiserver.pem #}
