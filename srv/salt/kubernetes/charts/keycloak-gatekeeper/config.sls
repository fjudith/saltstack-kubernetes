/srv/kubernetes/manifests/keycloak-gatekeeper:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/keycloak-gatekeeper/kcgk-injector.sh:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper
    - source: salt://kubernetes/charts/keycloak-gatekeeper/scripts/kcgk-injector.sh
    - user: root
    - group: root
    - mode: 555

/srv/kubernetes/manifests/keycloak-gatekeeper/realms.json:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper
    - source: salt://kubernetes/charts/keycloak-gatekeeper/templates/realms.json.j2
    - user: root
    - group: root
    - template: jinja
    - mode: 555

/srv/kubernetes/manifests/keycloak-gatekeeper/keycloak-kubernetes-admins-group.json:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper
    - source: salt://kubernetes/charts/keycloak-gatekeeper/files/keycloak-kubernetes-admins-group.json
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/keycloak-gatekeeper/keycloak-kubernetes-users-group.json:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper
    - source: salt://kubernetes/charts/keycloak-gatekeeper/files/keycloak-kubernetes-users-group.json
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/keycloak-gatekeeper/client-scopes.json:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper
    - source: salt://kubernetes/charts/keycloak-gatekeeper/files/client-scopes.json
    - user: root
    - group: root
    - template: jinja
    - mode: 644
