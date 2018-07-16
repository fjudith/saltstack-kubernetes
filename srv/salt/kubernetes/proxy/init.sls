{%- from "kubernetes/map.jinja" import common with context -%}

include:
  - tinyproxy
  - keepalived
  - haproxy

/root/.kube:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/usr/bin/kubectl:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ common.version }}/bin/linux/amd64/kubectl
    - skip_verify: True
    - show_changes: False
    - group: root
    - mode: 755

/root/.kube/config:
  file.managed:
    - source: salt://kubernetes/proxy/kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 640

/srv/kubernetes:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/srv/kubernetes/acme.json:
  file.managed:
    - source: salt://kubernetes/proxy/acme.json
    - user: root
    - group: root
    - mode: 600
    - replace: False