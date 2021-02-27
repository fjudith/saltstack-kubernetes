kube-apiserver-role-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/kube-apiserver-crb.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-apiserver-crb.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose

kubelet-role-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/kubelet-crb.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kubelet-crb.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose