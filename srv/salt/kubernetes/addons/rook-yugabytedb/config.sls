/srv/kubernetes/manifests/rook-yugabytedb:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/rook-yugabytedb/operator.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-yugabytedb
    - source: salt://{{ tpldir }}/templates/operator.yaml.j2
    - template: jinja
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-yugabytedb/cluster.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-yugabytedb
    - source: salt://{{ tpldir }}/templates/cluster.yaml.j2
    - template: jinja
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}