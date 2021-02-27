node-problem-detector-wait:
  cmd.run:
    - require:
      - cmd: node-problem-detector
    - runas: root
    - name: |
        kubectl -n kube-system wait pod --for=condition=Ready -l app=node-problem-detector
    - timeout: 180
