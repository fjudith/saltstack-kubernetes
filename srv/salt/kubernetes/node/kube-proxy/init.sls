{%- from "kubernetes/map.jinja" import common with context -%}

/usr/local/bin/kube-proxy:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ common.version }}/bin/linux/amd64/kube-proxy
    - skip_verify: true
    - group: root
    - mode: 755

/etc/systemd/system/kube-proxy.service:
  file.managed:
    - source: salt://kubernetes/node/kube-proxy/kube-proxy.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/var/lib/kube-proxy:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/etc/kubernetes/kube-proxy.kubeconfig:
  file.managed:
    - source: salt://kubernetes/node/kube-proxy/kube-proxy.kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/var/lib/kube-proxy/kube-proxy-config.yaml:
  file.managed:
    - source: salt://kubernetes/node/kube-proxy/kube-proxy-config.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kube-proxy.service:
  service.running:
    - watch:
      - file: /etc/systemd/system/kube-proxy.service
      - file: /etc/kubernetes/kube-proxy.kubeconfig
      - file: /var/lib/kube-proxy/kube-proxy-config.yaml
      - file: /usr/local/bin/kube-proxy
    - enable: True