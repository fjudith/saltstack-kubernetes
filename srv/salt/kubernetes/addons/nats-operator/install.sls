nats-operator:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/nats-operator/00-prereqs.yaml
        - file: /srv/kubernetes/manifests/nats-operator/nats-operator-deployment.yaml
    - runas: root    
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/00-prereqs.yaml
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/nats-operator-deployment.yaml
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

nats-streaming-operator:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/nats-operator/default-rbac.yaml
        - file: /srv/kubernetes/manifests/nats-operator/nats-streaming-operator-deployment.yaml
    - runas: root    
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/default-rbac.yaml
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/nats-streaming-operator-deployment.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'

query-nats-streaming-api:
  http.wait_for_successful_query:
    - watch:
      - cmd: nats-streaming-operator
    - name: http://127.0.0.1:8080/apis/streaming.nats.io/v1alpha1
    # - match: DaemonSet
    - wait_for: 120
    - request_interval: 5
    - status: 200

nats-streaming-cluster:
  cmd.run:
    - require:
        - http: query-nats-streaming-api
    - watch:
        - file: /srv/kubernetes/manifests/nats-operator/streaming-cluster.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/streaming-cluster.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'