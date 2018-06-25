{%- set rktVersion = pillar['kubernetes']['node']['runtime']['rkt']['version'] -%}

install_rkt:
  pkg.installed:
    - sources:
      - rkt: https://github.com/rkt/rkt/releases/download/v{{ rktVersion }}/rkt_{{ rktVersion }}-1_amd64.deb

/opt/bin:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/opt/bin/host-rkt:
    file.managed:
    - source: salt://node/cri/rkt/host-rkt
    - user: root
    - template: jinja
    - group: root
    - mode: 755
    - require:
      - pkg: install_rkt


/etc/systemd/system/load-rkt-stage1.service:
    file.managed:
    - source: salt://node/cri/rkt/load-rkt-stage1.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - require:
      - pkg: install_rkt

load-rkt-stage1:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/load-rkt-stage1.service
    - require:
      - pkg: install_rkt
    - watch:
      - file: /etc/systemd/system/load-rkt-stage1.service

/etc/systemd/system/rkt-api.service:
    file.managed:
    - source: salt://node/cri/rkt/rkt-api.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - require:
      - pkg: install_rkt

rkt-api:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/rkt-api.service
    - require:
      - pkg: install_rkt
    - watch:
      - file: /etc/systemd/system/rkt-api.service