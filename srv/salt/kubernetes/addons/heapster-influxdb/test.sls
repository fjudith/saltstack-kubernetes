query-heapster:
  cmd.run:
    - name: |
        http --check-status --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/api/v1/namespaces/kube-system/services/heapster/proxy
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10

query-influxdb:
  cmd.run:
    - name: |
        http --check-status --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/api/v1/namespaces/kube-system/services/monitoring-influxdb:http/proxy
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10

query-grafana:
  cmd.run:
    - name: |
        http --check-status --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/api/v1/namespaces/kube-system/services/monitoring-grafana/proxy
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10
