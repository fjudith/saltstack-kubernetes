nginx-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/nginx/nginx-ingress

nginx-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: /srv/kubernetes/manifests/nginx
      - file: nginx-remove-charts
    - cwd: /srv/kubernetes/manifests/nginx
    - name: |
        helm fetch --untar stable/nginx-ingress
