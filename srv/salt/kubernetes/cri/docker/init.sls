{%- from "kubernetes/map.jinja" import common with context -%}

{{ common.cri.docker.data_dir }}:
  file.directory:
    - user:  root
    - group:  root
    - mode:  '755'

/etc/docker:
  file.directory:
    - user:  root
    - group:  root
    - mode:  '744'

/opt/docker-v{{ common.cri.docker.version }}:
  archive.extracted:
    - source: https://download.docker.com/linux/static/stable/x86_64/docker-{{ common.cri.docker.version }}.tgz
    - skip_verify: true
    - archive_format: tar
    - if_missing: /opt/docker-v{{ common.cri.docker.version }}

/usr/bin/docker-containerd:
  file.symlink:
    - target: /opt/docker-v{{ common.cri.docker.version }}/docker-containerd

/usr/bin/docker-containerd-ctr:
  file.symlink:
    - target: /opt/docker-v{{ common.cri.docker.version }}/docker-containerd-ctr

/usr/bin/docker-containerd-shim:
  file.symlink:
    - target: /opt/docker-v{{ common.cri.docker.version }}/docker-containerd-shim

/usr/bin/dockerd:
  file.symlink:
    - target: /opt/docker-v{{ common.cri.docker.version }}/dockerd

/usr/bin/docker:
  file.symlink:
    - target: /opt/docker-v{{ common.cri.docker.version }}/docker

/usr/bin/docker-proxy:
  file.symlink:
    - target: /opt/docker-v{{ common.cri.docker.version }}/docker-proxy

/usr/bin/docker-runc:
  file.symlink:
    - target: /opt/docker-v{{ common.cri.docker.version }}/docker-runc

/etc/docker/daemon.json:
    file.managed:
    - source: salt://kubernetes/cri/docker/files/daemon.json
    - user: root
    - group: root
    - mode: 644
    
/etc/systemd/system/docker.socket:
    file.managed:
    - source: salt://kubernetes/cri/docker/files/docker.socket
    - user: root
    - group: root
    - mode: 644

/etc/systemd/system/docker.service:
    file.managed:
    - source: salt://kubernetes/cri/docker/files/docker.service
    - user: root
    - group: root
    - mode: 644

docker:
  group.present:
    - system: True

docker.socket:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/docker.socket
    - require:
      - group: docker

docker.service:
  service.enabled:
    - require:
      - group: docker
      - /etc/systemd/system/docker.service