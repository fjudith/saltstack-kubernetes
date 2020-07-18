/etc/etcd/pki:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/etc/etcd/etcd.env:
  file.managed:
    - require:
      - file:  /etc/etcd/pki
    - source: salt://{{ tpldir }}/templates/etcd.env.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}