contour-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/contour/values.yaml
      - cmd: contour-namespace
    - cwd: /srv/kubernetes/manifests/contour/contour
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/contour/contour/crds/ && \
        helm dependency update && \
        helm upgrade --install contour --namespace projectcontour \
          --values /srv/kubernetes/manifests/contour/values.yaml \
          "./" --timeout 5m
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'