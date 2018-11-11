{%- from "kubernetes/map.jinja" import common with context -%}

/tmp/kube-scheduler-{{ common.version }}:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ common.version }}/bin/linux/amd64/kube-scheduler
    - skip_verify: true
    - group: root
    - mode: 444

kube-scheduler-install:
  service.dead:
    - name: kube-scheduler.service
    - watch:
      - file: /tmp/kube-scheduler-{{ common.version }}
    - unless: cmp -s /usr/local/bin/kube-scheduler /tmp/kube-scheduler-{{ common.version }}
  file.copy:
    - name: /usr/local/bin/kube-scheduler
    - source: /tmp/kube-scheduler-{{ common.version }}
    - mode: 555
    - user: root
    - group: root
    - force: true
    - require:
      - file: /tmp/kube-scheduler-{{ common.version }}
    - unless: cmp -s /usr/local/bin/kube-scheduler /tmp/kube-scheduler-{{ common.version }}

/etc/systemd/system/kube-scheduler.service:    
    file.managed:
    - source: salt://kubernetes/role/master/kube-scheduler/files/kube-scheduler.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/kube-scheduler.kubeconfig:
  file.managed:
    - source: salt://kubernetes/role/master/kube-scheduler/files/kube-scheduler.kubeconfig
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
    - source: salt://kubernetes/role/master/kube-scheduler/files/kube-scheduler-config.yaml
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
      - file: /usr/local/bin/kube-scheduler
    - enable: True

query-kube-scheduler:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:10251/healthz'
    - match: ok
    - wait_for: 180
    - request_interval: 5
    - status: 200