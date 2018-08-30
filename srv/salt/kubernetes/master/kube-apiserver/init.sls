{%- from "kubernetes/map.jinja" import common with context -%}

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

/usr/local/bin/kube-apiserver:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ common.version }}/bin/linux/amd64/kube-apiserver
    - skip_verify: true
    - group: root
    - mode: 755

/etc/systemd/system/kube-apiserver.service:    
    file.managed:
    - source: salt://kubernetes/master/kube-apiserver/kube-apiserver.service
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
    - enable: True

query-kube-apiserver:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:8080/version'
    - match: {{ common.version }}
    - wait_for: 180
    - request_interval: 5
    - status: 200
