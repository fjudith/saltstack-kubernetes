/srv/kubernetes/manifests/weave:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/weave/weave.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/weave
    - source: salt://kubernetes/cni/weave/templates/weave.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

query-weave-required-api:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:8080/apis/apps/v1'
    - match: DaemonSet
    - wait_for: 180
    - request_interval: 5
    - status: 200

weave-install:
  cmd.run:
    - require:
      - http: query-weave-required-api
    - watch:
      - file: /srv/kubernetes/manifests/weave/weave.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/weave/weave.yaml