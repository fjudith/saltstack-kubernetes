{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}

/srv/kubernetes/manifests/keycloak:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/keycloak/values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/keycloak
    - source: salt://kubernetes/charts/keycloak/files/values.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/keycloak/keycloak-ingress.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/keycloak
    - source: salt://kubernetes/charts/keycloak/templates/ingress.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

keycloak:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/keycloak/values.yaml
      - file: /srv/kubernetes/manifests/keycloak/keycloak-ingress.yaml
    - runas: root
    - unless: helm list | grep keycloak
    - only_if: kubectl get storageclass | grep \(default\)
    - env:
      - HELM_HOME: /srv/helm/home
    - name: |
        helm install --name keycloak --namespace keycloak \
            -f /srv/kubernetes/manifests/keycloak/values.yaml \
            "stable/keycloak"
        kubectl apply -f /srv/kubernetes/manifests/keycloak/keycloak-ingress.yaml

