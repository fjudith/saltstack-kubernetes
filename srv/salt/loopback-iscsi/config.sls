{%- from tpldir ~ "/map.jinja" import loopback_iscsi with context -%}

{{ loopback_iscsi.path }}:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/etc/tgt/conf.d/loopback-iscsi.conf:
  file.managed:
    - source: salt://{{ tpldir }}/templates/loopback-iscsi.conf.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}