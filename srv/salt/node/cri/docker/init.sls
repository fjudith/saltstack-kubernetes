{%- set dockerVersion = pillar['kubernetes']['node']['runtime']['docker']['version'] -%}
{%- set dockerdata = pillar['kubernetes']['node']['runtime']['docker']['data-dir'] -%}

{{ dockerdata }}:
  file.directory:
    - user:  root
    - group:  root
    - mode:  '755'

/etc/docker:
  file.directory:
    - user:  root
    - group:  root
    - mode:  '744'

docker-latest-archive:
  archive.extracted:
    - name: /opt/
    - source: https://download.docker.com/linux/static/stable/x86_64/docker-{{ dockerVersion }}.tgz
    - skip_verify: true
    - archive_format: tar
    - if_missing: /opt/docker/

/usr/bin/docker-containerd:
  file.symlink:
    - target: /opt/docker/docker-containerd

/usr/bin/docker-containerd-ctr:
  file.symlink:
    - target: /opt/docker/docker-containerd-ctr

/usr/bin/docker-containerd-shim:
  file.symlink:
    - target: /opt/docker/docker-containerd-shim

/usr/bin/dockerd:
  file.symlink:
    - target: /opt/docker/dockerd

/usr/bin/docker:
  file.symlink:
    - target: /opt/docker/docker

/usr/bin/docker-proxy:
  file.symlink:
    - target: /opt/docker/docker-proxy

/usr/bin/docker-runc:
  file.symlink:
    - target: /opt/docker/docker-runc

/etc/docker/daemon.json:
    file.managed:
    - source: salt://node/cri/docker/daemon.json
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/systemd/system/docker.service:
    file.managed:
    - source: salt://node/cri/docker/docker.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/systemd/system/docker.socket:
    file.managed:
    - source: salt://node/cri/docker/docker.socket
    - user: root
    - template: jinja
    - group: root
    - mode: 644

docker:
  group.present:
    - gid: 1000
    - system: True

docker.socket:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/docker.service
    - require:
      - group: docker

docker.service:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/docker.service
    - require:
      - group: docker