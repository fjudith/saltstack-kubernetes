query-metrics-server:
  cmd.run:
    - watch:
      - cmd: metrics-server
    - name: |
        http --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/api/v1/namespaces/kube-system/services/https:metrics-server:https/proxy
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10