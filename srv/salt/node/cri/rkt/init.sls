{%- set rktVersion = pillar['kubernetes']['node']['runtime']['rkt']['version'] -%}

install_rkt:
  pkg.installed:
    - sources:
      - rkt: https://github.com/rkt/rkt/releases/download/v{{ rktVersion }}/rkt_{{ rktVersion }}-1_amd64.deb