{%- from "kubernetes/map.jinja" import common with context -%}

/tmp/kube-controller-manager-{{ common.version }}:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ common.version }}/bin/linux/amd64/kube-controller-manager
    - skip_verify: true
    - group: root
    - mode: 444

kube-controller-manager-install:
  service.dead:
    - name: kube-controller-manager.service
    - watch:
      - file: /tmp/kube-controller-manager-{{ common.version }}
    - unless: cmp -s /usr/local/bin/kube-controller-manager /tmp/kube-controller-manager-{{ common.version }}
  file.copy:
    - name: /usr/local/bin/kube-controller-manager
    - source: /tmp/kube-controller-manager-{{ common.version }}
    - mode: 555
    - user: root
    - group: root
    - force: true
    - require:
      - file: /tmp/kube-controller-manager-{{ common.version }}
    - unless: cmp -s /usr/local/bin/kube-controller-manager /tmp/kube-controller-manager-{{ common.version }}

/etc/kubernetes/kube-controller-manager.kubeconfig:
    file.managed:
    - source: salt://kubernetes/role/master/kube-controller-manager/files/kube-controller-manager.kubeconfig
    - user: root
    - group: root
    - mode: 644

/etc/systemd/system/kube-controller-manager.service:    
    file.managed:
    - source: salt://kubernetes/role/master/kube-controller-manager/templates/kube-controller-manager.service.j2
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

kube-controller-manager.service:
  service.running:
    - watch:
      - file: /etc/systemd/system/kube-controller-manager.service
      - file: /etc/kubernetes/kube-controller-manager.kubeconfig
      - file: /usr/local/bin/kube-controller-manager
    - enable: True

query-kube-controller-manager:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:10252/healthz'
    - match: ok
    - wait_for: 180
    - request_interval: 5
    - status: 200