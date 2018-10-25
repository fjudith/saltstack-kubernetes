{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}

keycloak:
  cmd.run:
    - runas: root
    - unless: helm list | grep keycloak
    - env:
      - HELM_HOME: /srv/helm/home
    - name: |
        helm install --name keycloak --namespace keycloak \
            {%- if master.storage.get('rook_ceph', {'enabled': False}).enabled %}
            --set postgresql.persistence.enabled=true \
            {%- endif %}
            --set keycloak.replicas=2 \
            --set keycloak.persistence.deployPostgres=true \
            --set keycloak.persistence.dbVendor=postgres \
            "stable/keycloak"

{% if common.addons.get('ingress_istio', {'enabled': False}).enabled -%}
/srv/kubernetes/manifests/keycloak-virtualservice.yaml:
  file.managed:
    - source: salt://kubernetes/charts/keycloak/istio/virtualservice.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

keycloak-virtualservice:
  cmd.run:
    - watch:
        - file:  /srv/kubernetes/manifests/keycloak-virtualservice.yaml
    - runas: root
    - use_vt: True
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
    - name: kubectl apply -f /srv/kubernetes/manifests/keycloak-virtualservice.yaml
{% endif %}