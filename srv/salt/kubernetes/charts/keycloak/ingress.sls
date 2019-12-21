keycloak-ingress:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/keycloak
    - name: /srv/kubernetes/manifests/keycloak/keycloak-ingress.yaml
    - source: salt://kubernetes/charts/keycloak/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
  cmd.run:
    - require:
      - cmd: keycloak
    - watch:
      - file: /srv/kubernetes/manifests/keycloak/keycloak-ingress.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/keycloak/keycloak-ingress.yaml
