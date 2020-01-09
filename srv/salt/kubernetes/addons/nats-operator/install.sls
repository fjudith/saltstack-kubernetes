nats-operator:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/nats-operator/00-prereqs.yaml
        - file: /srv/kubernetes/manifests/nats-operator/10-deployment.yaml
    - runas: root    
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/00-prereqs.yaml
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/10-deployment.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'


query-nats-api:
  http.wait_for_successful_query:
    - watch:
      - cmd: nats-operator
    - name: http://127.0.0.1:8080/apis/nats.io/v1alpha2
    # - match: DaemonSet
    - wait_for: 120
    - request_interval: 5
    - status: 200

nats-cluster:
  cmd.run:
    - require:
        - http: query-nats-api
    - watch:
        - file: /srv/kubernetes/manifests/nats-operator/cluster.yaml
    - runas: root    
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/cluster.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'