{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- set keycloak_password = salt['cmd.shell']("kubectl get secret --namespace keycloak keycloak-http -o jsonpath='{.data.password}' | base64 --decode; echo") -%}

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

keycloak-create-realm:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch: 
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/realms.json
    - runas: root
    - use_vt: true
    - name: |
        ./kcgk-injector.sh create-realm keycloak {{ keycloak_password }} https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ charts.keycloak_gatekeeper.realm }}

keycloak-create-groups:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch: 
      - cmd: keycloak-create-realm
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/keycloak-kubernetes-admins-group.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/keycloak-kubernetes-users-group.json
    - runas: root
    - use_vt: true
    - name: |
        ./kcgk-injector.sh create-groups keycloak {{ keycloak_password }} https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ charts.keycloak_gatekeeper.realm }}

keycloak-create-client-scopes:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch: 
      - cmd: keycloak-create-realm
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/client-scopes.json  
    - runas: root
    - use_vt: true
    - name: |
        ./kcgk-injector.sh create-client-scopes keycloak {{ keycloak_password }} https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ charts.keycloak_gatekeeper.realm }}

{% if common.addons.get('dashboard', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/keycloak-gatekeeper/files:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/keycloak-gatekeeper/kubernetes-dashboard.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/templates/kubernetes-dashboard.json.j2
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

/srv/kubernetes/manifests/keycloak-gatekeeper/groups-protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/files/groups-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: 644

/srv/kubernetes/manifests/keycloak-gatekeeper/files/keycloak-kubernetes-rbac.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/files
    - source: salt://kubernetes/charts/keycloak-gatekeeper/templates/keycloak-kubernetes-rbac.yaml.j2
    - user: root
    - group: root
    - template: jinja
    - mode: 644

keycloak-kubernetes-dashboard:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch:
      - cmd: keycloak-create-realm
      - cmd: keycloak-create-groups
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/kubernetes-dashboard.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/kubernetes-dashboard-protocolmapper.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/groups-protocolmapper.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/files/keycloak-kubernetes-rbac.yaml
    - runas: root
    - use_vt: true
    - name: |
        ./kcgk-injector.sh create-client-kubernetes keycloak {{ keycloak_password }} https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ charts.keycloak_gatekeeper.realm }} https://kubernetes-dashboard.{{ public_domain }}
{% endif %}

{% if common.addons.get('weave_scope', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/keycloak-gatekeeper/weave-scope.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/templates/weave-scope.json.j2
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
        ./kcgk-injector.sh create-client-weave-scope keycloak {{ keycloak_password }} https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ charts.keycloak_gatekeeper.realm }} https://scope.{{ public_domain }}
{% endif %}

{% if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/keycloak-gatekeeper/alertmanager.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/templates/alertmanager.json.j2
    - user: root
    - group: root
    - template: jinja
    - mode: 644

/srv/kubernetes/manifests/keycloak-gatekeeper/alertmanager-protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/files/alertmanager-protocolmapper.json
    - user: root
    - group: root
    - mode: 644

keycloak-alertmanager:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch:
      - cmd: keycloak-create-realm
      - cmd: keycloak-create-groups
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/alertmanager.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/alertmanager-protocolmapper.json
    - runas: root
    - use_vt: true
    - name: |
        ./kcgk-injector.sh create-client-alertmanager keycloak {{ keycloak_password }} https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ charts.keycloak_gatekeeper.realm }} https://alertmanager.{{ public_domain }}

/srv/kubernetes/manifests/keycloak-gatekeeper/prometheus.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/templates/prometheus.json.j2
    - user: root
    - group: root
    - template: jinja
    - mode: 644

/srv/kubernetes/manifests/keycloak-gatekeeper/prometheus-protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/files/prometheus-protocolmapper.json
    - user: root
    - group: root
    - mode: 644

keycloak-prometheus:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch:
      - cmd: keycloak-create-realm
      - cmd: keycloak-create-groups
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/prometheus.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/prometheus-protocolmapper.json
    - runas: root
    - use_vt: true
    - name: |
        ./kcgk-injector.sh create-client-prometheus keycloak {{ keycloak_password }} https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ charts.keycloak_gatekeeper.realm }} https://prometheus.{{ public_domain }}

{% endif %}

{% if master.storage.get('rook_ceph', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/keycloak-gatekeeper/rook-ceph.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/templates/rook-ceph.json.j2
    - user: root
    - group: root
    - template: jinja
    - mode: 644

/srv/kubernetes/manifests/keycloak-gatekeeper/rook-ceph-protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/files/rook-ceph-protocolmapper.json
    - user: root
    - group: root
    - mode: 644

keycloak-rook-ceph:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch:
      - cmd: keycloak-create-realm
      - cmd: keycloak-create-groups
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/rook-ceph.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/rook-ceph-protocolmapper.json
    - runas: root
    - use_vt: true
    - name: |
        ./kcgk-injector.sh create-client-rook-ceph keycloak {{ keycloak_password }} https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ charts.keycloak_gatekeeper.realm }} https://ceph.{{ public_domain }}
{% endif %}