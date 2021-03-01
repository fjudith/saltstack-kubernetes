containerd-daemon-dir:
  file.directory:
    - name: /etc/containerd
    - user: root
    - group: root
    - mode: "0755"

containerd-module:
  file.managed:
    - name: /etc/modules-load.d/containerd.conf
    - source: salt://{{ tpldir}}/files/containerd.conf
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - name: |
        modprobe overlay
        modprobe br_netfilter

/etc/containerd/config.toml:
  file.managed:
    - source: salt://{{ tpldir}}/templates/config.toml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

containerd.service:
  service.running:
    - watch:
      - pkg: containerd
      - file: /etc/modules-load.d/containerd.conf
      - file: /etc/containerd/config.toml
    - enable: True