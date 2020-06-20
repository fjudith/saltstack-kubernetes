node-problem-detector-wait:
  cmd.run:
    - require:
      - cmd: node-problem-detector
    - runas: root
    - name: |
        until kubectl -n kube-system get pods --field-selector=status.phase=Running --selector=app=node-problem-detector; do printf 'node-problem-detector is not Running' && sleep 5; done
    - timeout: 180
