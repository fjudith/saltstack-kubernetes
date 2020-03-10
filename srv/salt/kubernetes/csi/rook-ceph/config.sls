/srv/kubernetes/manifests/rook-ceph:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/rook-ceph/common.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/files/common.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/filesystem.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/files/filesystem.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/object.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/files/object.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/cluster.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/templates/cluster.yaml.j2
    - user: root
    - group: root
    - mode: 644
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
    - mode: 644
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/pool.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/files/pool.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/toolbox.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/templates/toolbox.yaml.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/prometheus-ceph-rules.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/files/prometheus-ceph-rules.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/prometheus.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/files/prometheus.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/prometheus-service.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/files/prometheus-service.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/service-monitor.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/files/service-monitor.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/kube-prometheus-prometheus.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/files/kube-prometheus-prometheus.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/ceph-exporter.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/templates/ceph-exporter.yaml.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/kube-prometheus-service-monitor.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/files/kube-prometheus-service-monitor.yaml
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/nfs.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/files/nfs.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-ceph/rook-ceph-ingress.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-ceph
    - source: salt://{{ tpldir }}/templates/ingress.yaml.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      tpldir: {{ tpldir }}