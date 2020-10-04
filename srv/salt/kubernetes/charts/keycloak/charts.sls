keycloak-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/keycloak/keycloak

keycloak-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: keycloak-remove-charts
      - file: /srv/kubernetes/manifests/keycloak
    - cwd: /srv/kubernetes/manifests/keycloak
    - name: |
        helm repo add codecentric https://codecentric.github.io/helm-charts
        helm fetch --untar codecentric/keycloak