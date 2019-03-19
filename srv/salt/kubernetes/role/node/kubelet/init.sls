{%- from "kubernetes/map.jinja" import common with context -%}

/etc/kubernetes/manifests:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/tmp/kubelet-{{ common.version }}:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ common.version }}/bin/linux/amd64/kubelet
    - skip_verify: true
    - group: root
    - mode: 444

kubelet-install:
  service.dead:
    - name: kubelet.service
    - watch:
      - file: /tmp/kubelet-{{ common.version }}
    - unless: cmp -s /usr/local/bin/kubelet /tmp/kubelet-{{ common.version }}
  file.copy:
    - name: /usr/local/bin/kubelet
    - source: /tmp/kubelet-{{ common.version }}
    - mode: 555
    - user: root
    - group: root
    - force: true
    - require:
      - file: /tmp/kubelet-{{ common.version }}
    - unless: cmp -s /usr/local/bin/kubelet /tmp/kubelet-{{ common.version }}

/etc/systemd/system/kubelet.service:
    file.managed:
    - source: salt://kubernetes/role/node/kubelet/templates/kubelet.service.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/kubelet.kubeconfig:
    file.managed:
    - source: salt://kubernetes/role/node/kubelet/templates/kubelet.kubeconfig.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/bootstrap.kubeconfig:
    file.managed:
    - source: salt://kubernetes/role/node/kubelet/templates/bootstrap.kubeconfig.jinja
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
    - source: salt://kubernetes/role/node/kubelet/templates/kubelet-config.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644
  
kubelet.service:
  service.running:
    - watch:
      - file: /etc/kubernetes/manifests
      - file: /etc/systemd/system/kubelet.service
      - file: /etc/kubernetes/kubelet.kubeconfig
      - file: /var/lib/kubelet/kubelet-config.yaml
      - file: /usr/local/bin/kubelet
    - enable: True
    - retry:
        attempt: 3
        interval: 10