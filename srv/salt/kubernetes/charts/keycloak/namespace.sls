keycloak-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/keycloak
    - name: /srv/kubernetes/manifests/keycloak/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/keycloak/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/keycloak/namespace.yaml
