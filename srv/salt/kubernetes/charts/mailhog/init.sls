{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}

/srv/kubernetes/manifests/mailhog-ingress.yaml:
  file.managed:
    - source: salt://kubernetes/charts/mailhog/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

mailhog:
  cmd.run:
    - runas: root
    # - unless: helm list | grep mailhog
    - name: |
        helm upgrade --install mailhog --namespace mailhog \
            --set env.MH_HOSTNAME=mail.{{ public_domain }} \
            "stable/mailhog"

mailhog-ingress:
    cmd.run:
      - require:
        - cmd: mailhog
      - watch:
        - file:  /srv/kubernetes/manifests/mailhog-ingress.yaml
      - runas: root
      - name: kubectl apply -f /srv/kubernetes/manifests/mailhog-ingress.yaml