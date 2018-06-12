keepalived.config:
 file.managed:
   - name: {{ salt['pillar.get']('keepalived:config_file_path', '/etc/keepalived/keepalived.conf') }}
   - source: salt://proxy/keepalived/templates/keepalived.jinja
   - template: jinja
   - user: root
   - group: root
   - mode: 644