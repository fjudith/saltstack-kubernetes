{%- from "kubernetes/map.jinja" import common with context -%}

rkt.install:
  pkg.installed:
    - sources:
      - rkt: https://github.com/rkt/rkt/releases/download/v{{ common.cri.rkt.version }}/rkt_{{ common.cri.rkt.version }}-1_amd64.deb

/opt/bin:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/opt/bin/host-rkt:
    file.managed:
    - source: salt://kubernetes/cri/rkt/scripts/host-rkt
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: rkt.install


/etc/systemd/system/load-rkt-stage1.service:
    file.managed:
    - source: salt://kubernetes/cri/rkt/files/load-rkt-stage1.service
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: rkt.install

load-rkt-stage1:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/load-rkt-stage1.service
    - require:
      - pkg: rkt.install
    - watch:
      - file: /etc/systemd/system/load-rkt-stage1.service

/etc/systemd/system/rkt-api.service:
    file.managed:
    - source: salt://kubernetes/cri/rkt/files/rkt-api.service
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: rkt.install

rkt-api:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/rkt-api.service
    - require:
      - pkg: rkt.install
    - watch:
      - file: /etc/systemd/system/rkt-api.service