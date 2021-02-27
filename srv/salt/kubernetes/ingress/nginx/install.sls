nginx-ingress-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/nginx/values.yaml
      - cmd: nginx-ingress-namespace
    - cwd: /srv/kubernetes/manifests/nginx/ingress-nginx
    - name: |
        helm dependency update && \
        helm upgrade --install nginx --namespace ingress-nginx \
          --values /srv/kubernetes/manifests/nginx/values.yaml \
          "./" --timeout 5m
    - onlyif: http --verify false https://localhost:6443/livez?verbose