{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}

/opt/fly-linux-amd64-v{{ charts.concourse.version }}:
  archive.extracted:
    - source: https://github.com/concourse/concourse/releases/download/v{{ charts.concourse.version }}/fly-{{ charts.concourse.version }}-linux-amd64.tgz
    - source_hash: {{ charts.concourse.source_hash }}
    - archive_format: tar
    - enforce_toplevel: false
    - if_missing: /opt/fly-linux-amd64-v{{ charts.concourse.version }}

/usr/local/bin/fly:
  file.symlink:
    - target: /opt/fly-linux-amd64-v{{ charts.concourse.version }}/fly


concourse:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/concourse/values.yaml
      - file: /srv/kubernetes/manifests/concourse/concourse/requirements.yaml
      - cmd: concourse-namespace
      - cmd: concourse-fetch-charts
    - cwd: /srv/kubernetes/manifests/concourse/concourse
    - name: |
        helm upgrade --install concourse --namespace concourse \
            --set concourse.web.externalUrl=https://{{ charts.concourse.ingress_host }}.{{ public_domain }} \
            --set concourse.worker.driver=detect \
            --set imageTag="{{ charts.concourse.version }}" \
            --set postgresql.enabled=true \
            --set postgresql.password={{ charts.concourse.db_password }} \
            {%- if master.storage.get('rook_ceph', {'enabled': False}).enabled %}
            --values /srv/kubernetes/manifests/concourse/values.yaml \
            {%- endif %}
            "./" --wait --timeout 5m