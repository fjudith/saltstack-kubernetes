{%- from tpldir ~ "/map.jinja" import loopback_iscsi with context -%}

iscsi-files:
  cmd.run:
    - require:
      - file: {{ loopback_iscsi.path }}
    - watch:
      - file: /etc/tgt/conf.d/loopback-iscsi.conf
    - user: root
    - cwd: {{ loopback_iscsi.path }}
    - name: |
      {%- for file in loopback_iscsi.files %}
        [ -f {{ file.name }} ] || fallocate --verbose --length {{ file.size }} {{ file.name }}
      {%- endfor %}

tgt-service:
  file.managed:
    - name: /etc/systemd/system/tgt.service
    - source: salt://{{ tpldir }}/templates/tgt.service.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}
  service.running:
    - name: tgt.service
    - watch:
      - file: /etc/tgt/conf.d/loopback-iscsi.conf
      - file: /etc/systemd/system/tgt.service
    - enable: True
    - reload: False
    - onlyif: systemctl daemon-reload

iscsi-discovery:
  cmd.run:
    - onchanges:
      - service: tgt-service
    - user: root
    - name: iscsiadm -m discovery -t st -p {{ loopback_iscsi.initiator_address }}:{{ loopback_iscsi.initiator_port }}

{%- for file in loopback_iscsi.files %}
{{ file.lun_name }}-authmethod:
  file.replace:
    - watch:
      - file: /etc/tgt/conf.d/loopback-iscsi.conf
      - service: tgt-service
    - name: /etc/iscsi/nodes/{{ loopback_iscsi.iqn }}:{{ file.lun_name }}/{{ loopback_iscsi.initiator_address }},{{ loopback_iscsi.initiator_port }},1/default
    - pattern: '^(node.session.auth.authmethod = )None$'
    - repl: '\1CHAP'

{{ file.lun_name }}-credentials:
  file.append:
    - watch:
      - file: /etc/tgt/conf.d/loopback-iscsi.conf
      - service: tgt-service
    - name: /etc/iscsi/nodes/{{ loopback_iscsi.iqn }}:{{ file.lun_name }}/{{ loopback_iscsi.initiator_address }},{{ loopback_iscsi.initiator_port }},1/default
    - text: |
        node.session.auth.username = {{ loopback_iscsi.incominguser.username }}
        node.session.auth.password = {{ loopback_iscsi.incominguser.password }}
        node.session.auth.username_in = {{ loopback_iscsi.outgoinguser.username }}
        node.session.auth.password_in = {{ loopback_iscsi.outgoinguser.password }}

{{ file.lun_name }}-startup:
  file.replace:
    - watch:
      - file: /etc/tgt/conf.d/loopback-iscsi.conf
      - service: tgt-service
    - name: /etc/iscsi/nodes/{{ loopback_iscsi.iqn }}:{{ file.lun_name }}/{{ loopback_iscsi.initiator_address }},{{ loopback_iscsi.initiator_port }},1/default
    - pattern: '^(node.startup = )manual$'
    - repl: '\1automatic'
{%- endfor %}

open-iscsi.service:
  service.running:
    - watch:
      {%- for file in loopback_iscsi.files %}
      - file: /etc/iscsi/nodes/{{ loopback_iscsi.iqn }}:{{ file.lun_name }}/{{ loopback_iscsi.initiator_address }},{{ loopback_iscsi.initiator_port }},1/default
      {%- endfor %}
    - enable: True
    - reload: True