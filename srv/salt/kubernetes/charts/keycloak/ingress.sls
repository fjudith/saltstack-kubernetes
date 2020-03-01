keycloak-ingress:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/keycloak
    - name: /srv/kubernetes/manifests/keycloak/keycloak-ingress.yaml
    - source: salt://{{ tpldir }}/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: keycloak
    - watch:
      - file: /srv/kubernetes/manifests/keycloak/keycloak-ingress.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/keycloak/keycloak-ingress.yaml
