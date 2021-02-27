kubernetes-dashboard-wait:
  cmd.run:
    - require:
      - cmd: kubernetes-dashboard
    - runas: root
    - name: |
        until kubectl -n kubernetes-dashboard get pods --field-selector=status.phase=Running --selector=k8s-app=kubernetes-dashboard; do printf 'kubernetes-dashboard is not Running' && sleep 5; done
        until kubectl -n kubernetes-dashboard get pods --field-selector=status.phase=Running --selector=k8s-app=dashboard-metrics-scraper; do printf 'dashboard-metrics-scraper is not Running' && sleep 5; done
    - timeout: 180

query-kubernetes-dashboard:
  cmd.run:
    - watch:
      - cmd: kubernetes-dashboard
      - cmd: kubernetes-dashboard-ingress
    - name: |
        http --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:443/proxy
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10