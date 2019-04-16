/srv/kubernetes/manifests/flannel:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/flannel/flannel.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/flannel
    - source: salt://kubernetes/cni/flannel/templates/flannel.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

query-fannel-required-api:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:8080/apis/extensions/v1beta1'
    - match: DaemonSet
    - wait_for: 180
    - request_interval: 5
    - status: 200

flannel-install:
  cmd.run:
    - require:
      - http: query-fannel-required-api
    - watch:
      - file: /srv/kubernetes/manifests/flannel/flannel.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/flannel/flannel.yaml