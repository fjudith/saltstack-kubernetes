kube-prometheus-teardown:
  cmd.run:
    - runas: root
    - name: |
        kubectl delete -f /srv/kubernetes/manifests/kube-prometheus/manifests/
    - onlyif: http --verify false https://localhost:6443/livez?verbose

/srv/kubernetes/manifests/kube-prometheus:
  file.absent:
    - require:
      - cmd: kube-prometheus-teardown 