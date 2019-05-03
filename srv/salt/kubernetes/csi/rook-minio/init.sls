{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}

/srv/kubernetes/manifests/rook-minio:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/rook-minio/minio-ingress.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-minio
    - source: salt://kubernetes/csi/rook-minio/templates/ingress.yaml.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja

/srv/kubernetes/manifests/rook-minio/object-store.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-minio
    - source: salt://kubernetes/csi/rook-minio/templates/object-store.yaml.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja

/srv/kubernetes/manifests/rook-minio/operator.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-minio
    - source: salt://kubernetes/csi/rook-minio/templates/operator.yaml.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja


rook-minio-operator-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/rook-minio/operator.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-minio/operator.yaml

rook-minio-operator-wait:
  cmd.run:
    - require:
      - cmd: rook-minio-operator-install
    - runas: root
    - name: until kubectl -n rook-minio-system get pods --field-selector=status.phase=Running | grep rook-minio-operator; do printf 'rook-minio-operator is not Running' && sleep 5; done
    - use_vt: True
    - timeout: 180

rook-minio-cluster-install:
  cmd.run:
    - require:
      - cmd: rook-minio-operator-wait
      - cmd: rook-minio-operator-install
    - watch:
      - file: /srv/kubernetes/manifests/rook-minio/object-store.yaml
      - file: /srv/kubernetes/manifests/rook-minio/minio-ingress.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-minio/object-store.yaml
        kubectl apply -f /srv/kubernetes/manifests/rook-minio/minio-ingress.yaml