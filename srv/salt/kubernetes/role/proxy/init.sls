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

/root/.kube/config:
  file.managed:
    - source: salt://kubernetes/role/proxy/templates/kubeconfig.jinja
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
    - source: salt://kubernetes/role/proxy/files/acme.json
    - user: root
    - group: root
    - mode: 600
    - replace: False