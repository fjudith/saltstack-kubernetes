{%- from "kubernetes/map.jinja" import common with context -%}

/usr/local/bin/kubelet:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ common.version }}/bin/linux/amd64/kubelet
    - skip_verify: true
    - group: root
    - mode: 755

/etc/systemd/system/kubelet.service:
  file.managed:
    - source: salt://kubernetes/node/kubelet/kubelet.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/kubelet.kubeconfig:
  file.managed:
    - source: salt://kubernetes/node/kubelet/kubelet.kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/bootstrap.kubeconfig:
  file.managed:
    - source: salt://kubernetes/node/kubelet/bootstrap.kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/var/lib/kubelet:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/var/lib/kubelet/kubelet-config.yaml:
  file.managed:
    - require:
      - file: /var/lib/kubelet
    - source: salt://kubernetes/node/kubelet/kubelet-config.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubelet.service:
  service.running:
    - require:
      - file: /etc/kubernetes/manifests
    - watch:
      - file: /etc/systemd/system/kubelet.service
      - file: /etc/kubernetes/kubelet.kubeconfig
      - file: /var/lib/kubelet/kubelet-config.yaml
      - file: /usr/local/bin/kubelet
    - enable: True