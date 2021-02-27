kubernetes-traefik-install:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/traefik/traefik.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/traefik/traefik.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose