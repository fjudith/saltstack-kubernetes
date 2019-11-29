{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}

/srv/kubernetes/manifests/mailhog:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/mailhog/ingress.yaml:
  file.managed:
    - source: salt://kubernetes/charts/mailhog/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

mailhog-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/mailhog
    - name: /srv/kubernetes/manifests/mailhog/namespace.yaml
    - source: salt://kubernetes/charts/mailhog/files/namespace.yaml
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/mailhog/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/mailhog/namespace.yaml

mailhog:
  cmd.run:
    - watch:
      - cmd: mailhog-namespace
    - runas: root
    - name: |
        helm upgrade --install mailhog --namespace mailhog \
            --set env.MH_HOSTNAME=mail.{{ public_domain }} \
            "stable/mailhog"

mailhog-ingress:
    cmd.run:
      - watch:
        - file: /srv/kubernetes/manifests/mailhog/ingress.yaml
        - cmd: mailhog-namespace
      - runas: root
      - name: kubectl apply -f /srv/kubernetes/manifests/mailhog/ingress.yaml