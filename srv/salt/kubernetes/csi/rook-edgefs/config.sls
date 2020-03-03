/srv/kubernetes/manifests/rook-edgefs:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/rook-edgefs/common.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - source: salt://{{ tpldir }}/files/common.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-edgefs/operator.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - source: salt://{{ tpldir }}/templates/operator.yaml.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-edgefs/cluster.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - source: salt://{{ tpldir }}/templates/cluster.yaml.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-edgefs/iscsi.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - source: salt://{{ tpldir }}/files/iscsi.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-edgefs/isgw.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - source: salt://{{ tpldir }}/files/isgw.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-edgefs/nfs.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - source: salt://{{ tpldir }}/files/nfs.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-edgefs/s3.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - source: salt://{{ tpldir }}/files/s3.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-edgefs/s3x.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - source: salt://{{ tpldir }}/files/s3x.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-edgefs/sslKeyCertificate.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - source: salt://{{ tpldir }}/files/sslKeyCertificate.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-edgefs/swift.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - source: salt://{{ tpldir }}/files/swift.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-edgefs/edgefs-iscsi-csi-driver-config.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - source: salt://{{ tpldir }}/templates/edgefs-iscsi-csi-driver-config.yaml.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-edgefs/edgefs-iscsi-csi-driver.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - source: salt://{{ tpldir }}/files/edgefs-iscsi-csi-driver.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-edgefs/edgefs-nfs-csi-driver-config.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - source: salt://{{ tpldir }}/templates/edgefs-nfs-csi-driver-config.yaml.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-edgefs/edgefs-nfs-csi-driver.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - source: salt://{{ tpldir }}/files/edgefs-nfs-csi-driver.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-edgefs/prometheus.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - source: salt://{{ tpldir }}/files/prometheus.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-edgefs/prometheus-service.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - source: salt://{{ tpldir }}/files/prometheus-service.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-edgefs/service-monitor.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - source: salt://{{ tpldir }}/files/service-monitor.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-edgefs/kube-prometheus-prometheus.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - source: salt://{{ tpldir }}/files/kube-prometheus-prometheus.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/rook-edgefs/kube-prometheus-service-monitor.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - source: salt://{{ tpldir }}/files/kube-prometheus-service-monitor.yaml
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      tpldir: {{ tpldir }}