traefik-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/traefik/traefik

traefik-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: /srv/kubernetes/manifests/traefik
      - file: traefik-remove-charts
    - cwd: /srv/kubernetes/manifests/traefik
    - name: |
        helm fetch --untar stable/traefik
