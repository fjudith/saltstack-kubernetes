{%- from "kubernetes/map.jinja" import common with context -%}

/usr/bin/kube-scheduler:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ common.version }}/bin/linux/amd64/kube-scheduler
    - skip_verify: true
    - group: root
    - mode: 755

/etc/kubernetes/kube-scheduler.kubeconfig:
  file.managed:
    - source: salt://kubernetes/master/kube-scheduler/kube-scheduler.kubeconfig
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

/var/lib/kube-scheduler:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/var/lib/kube-scheduler/kube-scheduler-config.yaml:
  file.managed:
    - require:
      - file: /var/lib/kube-scheduler
    - source: salt://kubernetes/master/kube-scheduler/kube-scheduler-config.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644