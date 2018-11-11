{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

/srv/kubernetes/manifests/concourse:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/tmp/fly_linux_amd64-v{{ charts.concourse.version }}:
  file.managed:
    - source: https://github.com/concourse/concourse/releases/download/v{{ charts.concourse.version }}/fly_linux_amd64
    - source_hash: {{ charts.concourse.source_hash }}
    - user: root
    - group: root
    - mode: 555

/usr/local/bin/fly:
  file.copy:
    - source: /tmp/fly_linux_amd64-v{{ charts.concourse.version }}
    - mode: 555
    - user: root
    - group: root
    - force: true
    - require:
      - file: /tmp/fly_linux_amd64-v{{ charts.concourse.version }}
    - unless: cmp -s /usr/local/bin/fly /tmp/fly_linux_amd64-v{{ charts.concourse.version }}

/srv/kubernetes/manifests/concourse/secrets:
  file.directory:
    - require:
      - file: /srv/kubernetes/manifests/concourse
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/concourse-ingress.yaml:
  file.managed:
    - source: salt://kubernetes/charts/concourse/templates/ingress.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

concourse:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/concourse
      - file: /srv/kubernetes/manifests/concourse-ingress.yaml
    - runas: root
    - unless: helm list | grep concourse
    - env:
      - HELM_HOME: /srv/helm/home
    - name: |
        helm install --name concourse --namespace concourse \
            --set concourse.web.externalUrl=https://ci.{{ public_domain }} \
            --set rbac.create=true \
            --set postgresql.enabled=true \
            --set postgresql.password={{ charts.concourse.db_password }} \
            {%- if master.storage.get('rook_ceph', {'enabled': False}).enabled %}
            --set persistence.enabled=true \
            --set postgresql.persistence.enabled=true \
             {%- endif %}
            "stable/concourse"
        - name: kubectl apply -f /srv/kubernetes/manifests/concourse-ingress.yaml
    