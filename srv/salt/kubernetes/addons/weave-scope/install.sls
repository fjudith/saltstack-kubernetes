weave-scope:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/weave-scope/sa.yaml
        - file: /srv/kubernetes/manifests/weave-scope/cluster-role.yaml
        - file: /srv/kubernetes/manifests/weave-scope/cluster-role-binding.yaml
        - file: /srv/kubernetes/manifests/weave-scope/deploy.yaml
        - file: /srv/kubernetes/manifests/weave-scope/ds.yaml
        - file: /srv/kubernetes/manifests/weave-scope/probe-deploy.yaml
        - file: /srv/kubernetes/manifests/weave-scope/svc.yaml
        - file: /srv/kubernetes/manifests/weave-scope/psp.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/sa.yaml
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/cluster-role.yaml
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/cluster-role-binding.yaml
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/deploy.yaml
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/ds.yaml
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/probe-deploy.yaml
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/svc.yaml
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/psp.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'