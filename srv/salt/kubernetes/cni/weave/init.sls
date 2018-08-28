/etc/kubernetes/manifests/weave.yaml:
    file.managed:
    - source: salt://kubernetes/cni/weave/weave.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

query-weave-required-api:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:8080/apis/extensions/v1beta1'
    - match: DaemonSet
    - wait_for: 900
    - request_interval: 5
    - status: 200

weave-install:
  cmd.run:
    - require:
      - http: query-weave-required-api
    - watch:
      - file: /etc/kubernetes/manifests/weave.yaml
    - runas: root
    - name: kubectl apply -f /etc/kubernetes/manifests/weave.yaml