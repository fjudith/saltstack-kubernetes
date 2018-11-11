{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}

/srv/kubernetes/manifests/spinnaker-ingress.yaml:
  file.managed:
    - source: salt://kubernetes/charts/spinnaker/templates/ingress.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

spinnaker:
  cmd.run:
    - watch:
        - file:  /srv/kubernetes/manifests/spinnaker-ingress.yaml
    - runas: root
    - unless: helm list | grep spinnaker
    - env:
      - HELM_HOME: /srv/helm/home
    - name: |
        helm install --name spinnaker --namespace spinnaker \
            {%- if master.storage.get('rook_minio', {'enabled': False}).enabled %}
            --set minio.enabled=false \
            --set s3.enabled=true \
            --set s3.bucket=spinnaker \
            --set s3.endpoint=https://minio.{{ public_domain }} \
            --set s3.accessKey={{ salt.hashutil.base64_decodestring('VzM0VjNMNEJNSU5JTzRDQzNTU0szWQ==') }} \
            --set s3.secretKey={{ salt.hashutil.base64_decodestring('VzM0VjNMNEJNSU5JT1MzQ1IzVEszWQ==') }} \
            --set redis.master.persistence.enabled=true \
            {%- endif %}
            --set redis.cluster.enabled=true \
            "stable/spinnaker"
        kubectl apply -f /srv/kubernetes/manifests/spinnaker-ingress.yaml