/srv/kubernetes/manifests/canal:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/canal/canal-rbac.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/canal
    - source: salt://kubernetes/cni/canal/files/canal-rbac.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/canal/canal.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/canal
    - source: salt://kubernetes/cni/canal/templates/canal.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

query-canal-required-api:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:8080/apis/extensions/v1beta1'
    - match: DaemonSet
    - wait_for: 180
    - request_interval: 5
    - status: 200

canal-install:
  cmd.run:
    - require:
      - http: query-canal-required-api
    - watch:
      - file: /srv/kubernetes/manifests/canal/canal-rbac.yaml
      - file: /srv/kubernetes/manifests/canal/canal.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/canal/canal-rbac.yaml
        kubectl apply -f /srv/kubernetes/manifests/canal/canal.yaml