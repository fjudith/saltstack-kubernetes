/etc/systemd/system/containerd.service:
  file.managed:
    - source: salt://{{ tpldir }}/files/containerd.service
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/etc/systemd/system/kubelet.service.d:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/etc/systemd/system/kubelet.service.d/0-containerd.conf:
  file.managed:
    - require:
      - file: /etc/systemd/system/kubelet.service.d
    - source: salt://{{ tpldir }}/files/0-containerd.conf
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/etc/containerd:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/etc/containerd/config.toml:
  file.managed:
    - require:
      - file: /etc/containerd
    - source: salt://{{ tpldir }}/files/config.toml
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

containerd.service:
  service.running:
    - watch:
      - containerd-install
      - file: /etc/systemd/system/containerd.service
      - file: /etc/containerd/config.toml
    - enable: True