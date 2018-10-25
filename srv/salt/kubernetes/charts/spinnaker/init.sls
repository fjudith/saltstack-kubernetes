{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}


spinnaker:
  cmd.run:
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

/srv/kubernetes/manifests/spinnaker-ingress.yaml:
  file.managed:
    - source: salt://kubernetes/charts/spinnaker/ingress.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

spinnaker-ingress:
  cmd.run:
    - watch:
        - file:  /srv/kubernetes/manifests/spinnaker-ingress.yaml
    - runas: root
    - use_vt: True
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
    - name: kubectl apply -f /srv/kubernetes/manifests/spinnaker-ingress.yaml