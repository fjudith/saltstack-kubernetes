{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

/srv/kubernetes/manifests/keycloak-gatekeeper:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

helm-charts:
  git.latest:
    - name: https://github.com/fjudith/charts
    - target: /srv/kubernetes/charts
    - force_reset: True
    - rev: {{ charts.keycloak_gatekeeper.version }}

/srv/kubernetes/manifests/keycloak-gatekeeper/kcclient.sh:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper
    - source: salt://kubernetes/charts/keycloak-gatekeeper/scripts/kcclient.sh
    - user: root
    - group: root
    - mode: 555

/srv/kubernetes/manifests/keycloak-gatekeeper/realms.json:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper
    - source: salt://kubernetes/charts/keycloak-gatekeeper/templates/realms.json.jinja
    - user: root
    - group: root
    - template: jinja
    - mode: 555

/srv/kubernetes/manifests/keycloak-gatekeeper/groups.json:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper
    - source: salt://kubernetes/charts/keycloak-gatekeeper/templates/groups.json.jinja
    - user: root
    - group: root
    - template: jinja
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

keycloak-create-realm:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch: 
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/realms.json
    - runas: root
    - use_vt: true
    - name: |
        ./kcclient.sh create-realm keycloak $(kubectl get secret --namespace keycloak keycloak-http -o jsonpath="{.data.password}" | base64 --decode; echo) https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ charts.keycloak_gatekeeper.realm }}

keycloak-create-groups:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch: 
      - cmd: keycloak-create-realm
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/groups.json  
    - runas: root
    - use_vt: true
    - name: |
        ./kcclient.sh create-groups keycloak $(kubectl get secret --namespace keycloak keycloak-http -o jsonpath="{.data.password}" | base64 --decode; echo) https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ charts.keycloak_gatekeeper.realm }}

keycloak-create-client-scopes:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch: 
      - cmd: keycloak-create-realm
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/client-scopes.json  
    - runas: root
    - use_vt: true
    - name: |
        ./kcclient.sh create-client-scopes keycloak $(kubectl get secret --namespace keycloak keycloak-http -o jsonpath="{.data.password}" | base64 --decode; echo) https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ charts.keycloak_gatekeeper.realm }}

{% if common.addons.get('dashboard', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/keycloak-gatekeeper/files:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/keycloak-gatekeeper/kubernetes-dashboard.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/templates/kubernetes-dashboard.json.jinja
    - user: root
    - group: root
    - template: jinja
    - mode: 644

/srv/kubernetes/manifests/keycloak-gatekeeper/kubernetes-dashboard-protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/files/kubernetes-dashboard-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: 644

/srv/kubernetes/manifests/keycloak-gatekeeper/files/keycloak-admin-rbac.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/files
    - source: salt://kubernetes/charts/keycloak-gatekeeper/files/keycloak-admin-rbac.yaml
    - user: root
    - group: root
    - mode: 644

keycloak-kubernetes-dashboard:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch:
      - cmd: keycloak-create-realm
      - cmd: keycloak-create-groups
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/kubernetes-dashboard.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/kubernetes-dashboard-protocolmapper.json
    - runas: root
    - use_vt: true
    - name: |
        ./kcclient.sh create-client-kubernetes keycloak $(kubectl get secret --namespace keycloak keycloak-http -o jsonpath="{.data.password}" | base64 --decode; echo) https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ charts.keycloak_gatekeeper.realm }} https://kubernetes-dashboard.{{ public_domain }}
{% endif %}

{% if common.addons.get('weave_scope', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/keycloak-gatekeeper/weave-scope.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/templates/weave-scope.json.jinja
    - user: root
    - group: root
    - template: jinja
    - mode: 644

/srv/kubernetes/manifests/keycloak-gatekeeper/weave-scope-protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/files/weave-scope-protocolmapper.json
    - user: root
    - group: root
    - mode: 644

keycloak-weave-scope:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch:
      - cmd: keycloak-create-realm
      - cmd: keycloak-create-groups
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/weave-scope.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/weave-scope-protocolmapper.json
    - runas: root
    - use_vt: true
    - name: |
        ./kcclient.sh create-client-weave-scope keycloak $(kubectl get secret --namespace keycloak keycloak-http -o jsonpath="{.data.password}" | base64 --decode; echo) https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ charts.keycloak_gatekeeper.realm }} https://scope.{{ public_domain }}
{% endif %}