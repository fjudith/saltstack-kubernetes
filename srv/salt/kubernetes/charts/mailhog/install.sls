{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

mailhog:
  cmd.run:
    - watch:
      - cmd: mailhog-fetch-charts
      - cmd: mailhog-namespace
    - runas: root
    - cwd: /srv/kubernetes/manifests/mailhog/mailhog
    - name: |
        helm upgrade --install mailhog --namespace mailhog \
            --set env.MH_HOSTNAME={{ charts.mailhog.ingress_host }}.{{ public_domain }} \
            "./" --wait --timeout 3m