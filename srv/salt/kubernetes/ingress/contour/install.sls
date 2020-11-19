contour-install:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/contour/values.yaml
      - cmd: contour-namespace
      - cmd: contour-fetch-charts
    - cwd: /srv/kubernetes/manifests/contour/contour
    - name: |
        kubectl apply -f ./crds/ && \
        helm upgrade --install contour --namespace projectcontour \
          --values /srv/kubernetes/manifests/contour/values.yaml \
          bitnami/contour --timeout 5m
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'