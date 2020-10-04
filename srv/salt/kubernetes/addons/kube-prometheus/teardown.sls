kube-prometheus-teardown:
  cmd.run:
    - runas: root
    - name: |
        kubectl delete -f /srv/kubernetes/manifests/kube-prometheus/manifests/
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

/srv/kubernetes/manifests/kube-prometheus:
  file.absent:
    - require:
      - cmd: kube-prometheus-teardown 