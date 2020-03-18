kubernetes-traefik-install:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/traefik/traefik.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/traefik/traefik.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'