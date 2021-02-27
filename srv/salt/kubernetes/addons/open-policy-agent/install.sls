open-policy-agent:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/open-policy-agent/gatekeeper.yaml
        - cmd: open-policy-agent-namespace
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/open-policy-agent/gatekeeper.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose
