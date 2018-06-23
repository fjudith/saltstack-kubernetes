/srv/kubernetes/manifests:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/flannel.yaml:
    file.managed:
    - source: salt://node/cni/flannel/flannel.tmpl.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kube-apiserver-crb.yaml:
    file.managed:
    - source: salt://kubernetes/kube-apiserver-crb/kube-apiserver-crb.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kubelet-crb.yaml:
    file.managed:
    - source: salt://kubernetes/kubelet-crb/kubelet-crb.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/influxdb-grafana.yaml:
    file.managed:
    - source: salt://kubernetes/influxdb-grafana/influxdb-grafana.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/coredns.yaml:
    file.managed:
    - source: salt://kubernetes/coredns/coredns.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/dns-horizontal-autoscaler.yaml:
    file.managed:
    - source: salt://kubernetes/dns-horizontal-autoscaler/dns-horizontal-autoscaler.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/heapster.yaml:
    file.managed:
    - source: salt://kubernetes/heapster/heapster.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kube-dashboard.yaml:
    file.managed:
    - source: salt://kubernetes/kube-dashboard/kube-dashboard.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/traefik.yaml:
    file.managed:
    - source: salt://kubernetes/traefik/traefik.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644