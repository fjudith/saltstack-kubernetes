/etc/kubernetes/manifests/canal-rbac.yaml:
    file.managed:
    - source: salt://kubernetes/cni/canal/canal-rbac.yaml
    - user: root
    #- template: jinja
    - group: root
    - mode: 644

/etc/kubernetes/manifests/canal.yaml:
    file.managed:
    - source: salt://kubernetes/cni/canal/canal.yaml
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
      - file: /etc/kubernetes/manifests/canal-rbac.yaml
      - file: /etc/kubernetes/manifests/canal.yaml
    - runas: root
    - name: |
        kubectl apply -f /etc/kubernetes/manifests/canal-rbac.yaml
        kubectl apply -f /etc/kubernetes/manifests/canal.yaml