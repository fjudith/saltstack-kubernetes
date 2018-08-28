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

/usr/bin/kube-apiserver:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ common.version }}/bin/linux/amd64/kube-apiserver
    - skip_verify: true
    - group: root
    - mode: 755

/etc/kubernetes/manifests/kube-apiserver.yaml:
    file.managed:
    - source: salt://kubernetes/master/kube-apiserver/kube-apiserver.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644