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