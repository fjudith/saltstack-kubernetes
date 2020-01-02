kubernetes-metallb-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/metallb/values.yaml
    - name: |
        helm upgrade --install \
          metallb \
          --namespace metallb-system \
          --values /srv/kubernetes/manifests/metallb/values.yaml \
          stable/metallb
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'