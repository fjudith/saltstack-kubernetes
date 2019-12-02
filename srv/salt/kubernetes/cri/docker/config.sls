docker-daemon-dir:
  file.directory:
    - name: /etc/docker
    - user: root
    - group: root
    - mode: 755

/etc/docker/daemon.json:
    file.managed:
    - source: salt://kubernetes/cri/docker/files/daemon.json
    - user: root
    - group: root
    - mode: 644

docker.service:
  service.running:
    - watch:
      - pkg: docker-ce
      - file: /etc/docker/daemon.json
    - enable: True