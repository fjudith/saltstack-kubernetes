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
    - source: salt://kubernetes/cri/docker/daemon.json
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/systemd/system/docker-docker0.service:
    file.managed:
    - source: salt://kubernetes/cri/docker/docker-docker0.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/systemd/network/90-docker0.netdev:
    file.managed:
    - source: salt://kubernetes/cri/docker/90-docker0.netdev
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/systemd/network/91-docker0.network:
    file.managed:
    - source: salt://kubernetes/cri/docker/91-docker0.network
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    
/etc/systemd/system/sockets.target.wants/docker.socket:
    file.managed:
    - source: salt://kubernetes/cri/docker/docker.socket
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/systemd/system/docker.service:
    file.managed:
    - source: salt://kubernetes/cri/docker/docker.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

docker:
  group.present:
    - system: True

{# docker-docker0.service:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/docker-docker0.service
    - require:
      - group: docker #}

docker.socket:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/sockets.target.wants/docker.socket
    - require:
      - group: docker

docker.service:
  service.enabled:
    - watch:
      - /etc/systemd/system/docker.service
    - require:
      - group: docker