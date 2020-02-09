{%- from "kubernetes/map.jinja" import common with context -%}

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
    - wait_for: 120
    - request_interval: 5
    - status: 200

nats-cluster:
  cmd.run:
    - require:
        - http: query-nats-api
    - watch:
        - file: /srv/kubernetes/manifests/nats-operator/nats-cluster.yaml
    - runas: root    
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/nats-cluster.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'

stan-operator:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/nats-operator/default-rbac.yaml
        - file: /srv/kubernetes/manifests/nats-operator/stan-operator-deployment.yaml
    - runas: root    
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/default-rbac.yaml
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/stan-operator-deployment.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'

query-stan-api:
  http.wait_for_successful_query:
    - watch:
      - cmd: stan-operator
    - name: http://127.0.0.1:8080/apis/streaming.nats.io/v1alpha1
    - wait_for: 120
    - request_interval: 5
    - status: 200

stan-cluster:
  cmd.run:
    - require:
        - http: query-stan-api
    - watch:
        - file: /srv/kubernetes/manifests/nats-operator/stan-cluster.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/stan-cluster.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'