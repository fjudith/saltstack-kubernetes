{%- from "kubernetes/map.jinja" import common with context -%}

/etc/kubernetes/audit-policy.yaml:    
    file.managed:
    - source: salt://kubernetes/role/master/kube-apiserver/files/audit-policy.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/encryption-config.yaml:    
    file.managed:
    - source: salt://kubernetes/role/master/kube-apiserver/templates/encryption-config.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/tmp/kube-apiserver-{{ common.version }}:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ common.version }}/bin/linux/amd64/kube-apiserver
    - skip_verify: true
    - group: root
    - mode: 444

kube-apiserver-install:
  service.dead:
    - name: kube-apiserver.service
    - watch:
      - file: /tmp/kube-apiserver-{{ common.version }}
    - unless: cmp -s /usr/local/bin/kube-apiserver /tmp/kube-apiserver-{{ common.version }}
  file.copy:
    - name: /usr/local/bin/kube-apiserver
    - source: /tmp/kube-apiserver-{{ common.version }}
    - mode: 555
    - user: root
    - group: root
    - force: true
    - require:
      - file: /tmp/kube-apiserver-{{ common.version }}
    - unless: cmp -s /usr/local/bin/kube-apiserver /tmp/kube-apiserver-{{ common.version }}

/etc/systemd/system/kube-apiserver.service:    
    file.managed:
    - source: salt://kubernetes/role/master/kube-apiserver/templates/kube-apiserver.service.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kube-apiserver.service:
  service.running:
    - watch:
      - file: /etc/systemd/system/kube-apiserver.service
      - file: /etc/kubernetes/encryption-config.yaml
      - file: /etc/kubernetes/audit-policy.yaml
      - file: /usr/local/bin/kube-apiserver
    - enable: True

query-kube-apiserver:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:8080/healthz'
    - match: ok
    - wait_for: 180
    - request_interval: 5
    - status: 200
