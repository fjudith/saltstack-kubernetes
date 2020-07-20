nginx-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/nginx/ingress-nginx

nginx-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: /srv/kubernetes/manifests/nginx
      - file: nginx-remove-charts
    - cwd: /srv/kubernetes/manifests/nginx
    - name: |
        helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
        helm fetch --untar ingress-nginx/ingress-nginx
