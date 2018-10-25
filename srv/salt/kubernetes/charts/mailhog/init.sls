{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}


mailhog:
  cmd.run:
    - runas: root
    - unless: helm list | grep mailhog
    - env:
      - HELM_HOME: /srv/helm/home
    - name: |
        helm install --name mailhog --namespace mailhog \
            --set env.MH_HOSTNAME=mail.{{ public_domain }} \
            "stable/mailhog"

/srv/kubernetes/manifests/mailhog-ingress.yaml:
  file.managed:
    - source: salt://kubernetes/charts/mailhog/ingress.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

mailhog-ingress:
  cmd.run:
    - watch:
        - file:  /srv/kubernetes/manifests/mailhog-ingress.yaml
    - runas: root
    - use_vt: True
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
    - name: kubectl apply -f /srv/kubernetes/manifests/mailhog-ingress.yaml