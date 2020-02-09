kube-prometheus-crds:
  cmd.run:
    - watch:
      - git: kube-prometheus-repo
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/manifests/setup/
    - unless: curl --silent 'http://127.0.0.1:8080/apis/monitoring.coreos.com/v1'

kube-prometheus-query-api:
  http.wait_for_successful_query:
    - watch:
      - cmd: kube-prometheus-crds
    - name: 'http://127.0.0.1:8080/apis/monitoring.coreos.com/v1'
    - match: servicemonitors
    - wait_for: 180
    - request_interval: 5
    - status: 200

kube-prometheus:
  cmd.run:
    - watch:
      - git: kube-prometheus-repo
      - http: kube-prometheus-query-api
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/manifests/
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'