{%- set cniProvider = pillar['kubernetes']['node']['networking']['provider'] -%}
{%- set k8sVersion = pillar['kubernetes']['binary-version'] -%}

include:
  - proxy.keepalived
  - proxy.tinyproxy
  - proxy.haproxy

/root/.kube:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/usr/bin/kubectl:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8sVersion }}/bin/linux/amd64/kubectl
    - skip_verify: True
    - show_changes: False
    - group: root
    - mode: 755

/root/.kube/config:
  file.managed:
    - source: salt://proxy/kubeconfig
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
    - source: salt://proxy/acme.json
    - user: root
    - group: root
    - mode: 600
    - replate: False