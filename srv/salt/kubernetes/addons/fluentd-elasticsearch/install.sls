fluentd-elasticsearch:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/fluentd-elasticsearch
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/fluentd-elasticsearch/
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
