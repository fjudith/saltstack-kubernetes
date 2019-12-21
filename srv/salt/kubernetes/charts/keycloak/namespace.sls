keycloak-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/keycloak
    - name: /srv/kubernetes/manifests/keycloak/namespace.yaml
    - source: salt://kubernetes/charts/keycloak/files/namespace.yaml
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/keycloak/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/keycloak/namespace.yaml
