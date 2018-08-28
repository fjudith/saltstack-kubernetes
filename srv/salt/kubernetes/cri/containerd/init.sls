{%- set version = pillar['kubernetes']['common']['cri']['containerd']['version'] -%}

libseccomp2.install:
  pkg.installed:
    - name: libseccomp2

btrfs.install:
  pkg.installed:
    - name: btrfs-tools

containerd-archive:
  archive.extracted:
    - name: /
    - source: https://storage.googleapis.com/cri-containerd-release/cri-containerd-{{ version }}.linux-amd64.tar.gz
    - skip_verify: true
    - archive_format: tar
    - if_missing: /opt/containerd/

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
    - source: salt://kubernetes/cri/containerd/0-containerd.conf
    - user: root
    - template: jinja
    - group: root
    - mode: 644

containerd.service:
  service.running:
    - enable: True