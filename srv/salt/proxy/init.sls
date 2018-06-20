{%- set cniProvider = pillar['kubernetes']['node']['networking']['provider'] -%}
{%- set k8sVersion = pillar['kubernetes']['version'] -%}

include:
  - node.cri.docker
  - node.cri.rkt
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
    - skip_verify: true
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

{% if cniProvider == "calico" %}
/opt/calico.yaml:
    file.managed:
    - source: salt://node/cni/calico/calico.tmpl.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644
{% endif %}