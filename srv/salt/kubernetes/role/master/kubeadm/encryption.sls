/etc/kubernetes/pki:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: true

/etc/kubernetes/pki/encryption-config.yaml:
  file.managed:
    - require:
      - file: /etc/kubernetes/pki
    - source: salt://{{ tpldir }}/templates/encryption-config.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}