/srv/kubernetes/manifests/rook-ceph:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/rook-ceph/crds.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/files/crds.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/common.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/files/common.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/cluster.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/templates/cluster.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/operator.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/templates/operator.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/ceph-client.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/files/ceph-client.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
