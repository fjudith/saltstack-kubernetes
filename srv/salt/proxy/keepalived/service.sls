keepalived.service:
  service.running:
    - name: keepalived
    - enable: True
    - reload: True
    - require:
      - pkg: keepalived
    - watch:
      - file: keepalived.config