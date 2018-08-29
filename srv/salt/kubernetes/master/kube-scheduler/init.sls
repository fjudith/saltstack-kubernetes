{%- from "kubernetes/map.jinja" import common with context -%}

/usr/local/bin/kube-scheduler:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ common.version }}/bin/linux/amd64/kube-scheduler
    - skip_verify: true
    - group: root
    - mode: 755

/etc/systemd/system/kube-scheduler.service:    
    file.managed:
    - source: salt://kubernetes/master/kube-scheduler/kube-scheduler.service
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

kube-scheduler.service:
  service.running:
    - watch:
      - file: /etc/systemd/system/kube-scheduler.service
      - file: /etc/kubernetes/kube-scheduler.kubeconfig
      - file: /var/lib/kube-scheduler/kube-scheduler-config.yaml
    - enable: True