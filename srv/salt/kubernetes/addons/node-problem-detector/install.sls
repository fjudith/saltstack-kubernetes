node-problem-detector:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/node-problem-detector/node-problem-detector-config.yaml
      - file: /srv/kubernetes/manifests/node-problem-detector/node-problem-detector.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/node-problem-detector/
    - onlyif: http --verify false https://localhost:6443/livez?verbose