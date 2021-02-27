fluentd-elasticsearch:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/fluentd-elasticsearch
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/fluentd-elasticsearch/
    - onlyif: http --verify false https://localhost:6443/livez?verbose
