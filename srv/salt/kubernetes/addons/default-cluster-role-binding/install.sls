kube-apiserver-role-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/kube-apiserver-crb.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-apiserver-crb.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

kubelet-role-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/kubelet-crb.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kubelet-crb.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'