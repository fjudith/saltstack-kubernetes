{%- from "kubernetes/map.jinja" import common with context -%}

libseccomp2.install:
  pkg.installed:
    - name: libseccomp2

btrfs.install:
  pkg.installed:
    - name: btrfs-tools

/tmp/containerd-v{{ common.cri.containerd.version }}:
  archive.extracted:
    - source: https://github.com/containerd/containerd/releases/download/v{{ common.cri.containerd.version }}/containerd-{{ common.cri.containerd.version }}.linux-amd64.tar.gz
    - source_hash: {{ common.cri.containerd.source_hash }}
    - archive_format: tar

containerd-install:
  service.dead:
    - name: containerd.service
    - watch:
      - archive: /tmp/containerd-v{{ common.cri.containerd.version }}
    - unless: cmp -s /usr/local/bin/containerd /tmp/containerd-v{{ common.cri.containerd.version }}/bin/containerd
  file.copy:
    - name: /usr/local/bin
    - source: /tmp/containerd-v{{ common.cri.containerd.version }}/bin
    - user: root
    - group: root
    - mode: 555
    - unless: cmp -s /usr/local/bin/containerd /tmp/containerd-v{{ common.cri.containerd.version }}/bin/containerd
    
/etc/systemd/system/containerd.service:
  file.managed:
    - source: salt://kubernetes/cri/containerd/files/containerd.service
    - user: root
    - group: root
    - mode: 644

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
    - source: salt://kubernetes/cri/containerd/files/0-containerd.conf
    - user: root
    - group: root
    - mode: 644

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
    - source: salt://kubernetes/cri/containerd/files/config.toml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

containerd.service:
  service.running:
    - watch:
      - containerd-install
      - file: /etc/systemd/system/containerd.service
      - file: /etc/containerd/config.toml
    - enable: True