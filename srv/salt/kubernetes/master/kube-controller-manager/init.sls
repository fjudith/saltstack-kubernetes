{%- from "kubernetes/map.jinja" import common with context -%}

/usr/bin/kube-controller-manager:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ common.version }}/bin/linux/amd64/kube-controller-manager
    - skip_verify: true
    - group: root
    - mode: 755

/etc/kubernetes/kube-controller-manager.kubeconfig:
    file.managed:
    - source: salt://kubernetes/master/kube-controller-manager/kube-controller-manager.kubeconfig
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

/var/lib/kube-controller-manager:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True