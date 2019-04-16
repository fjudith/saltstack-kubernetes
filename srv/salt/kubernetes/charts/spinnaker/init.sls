{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}

/srv/kubernetes/manifests/spinnaker-ingress.yaml:
  file.managed:
    - source: salt://kubernetes/charts/spinnaker/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

spinnaker:
  cmd.run:
    - runas: root
    - unless: helm list | grep spinnaker
    - only_if: kubectl get storageclass | grep \(default\)
    - env:
      - HELM_HOME: /srv/helm/home
    - name: |
        helm install --name spinnaker --namespace spinnaker \
            {%- if master.storage.get('rook_minio', {'enabled': False}).enabled %}
            --set minio.enabled=false \
            --set s3.enabled=true \
            --set s3.bucket=spinnaker \
            --set s3.endpoint=https://minio.{{ public_domain }} \
            --set s3.accessKey={{ master.storage.rook_minio.username }} \
            --set s3.secretKey={{ master.storage.rook_minio.password }} \
            {%- else -%}
            --set minio.enabled=true \
            --set minio.persistence.enabled=true \
            {%- endif %}
            --set redis.enabled=true \
            --set redis.cluster.enabled=true \
            --set redis.master.persistence.enabled=true \
            "stable/spinnaker" --timeout 600

spinnaker-ingress:
    cmd.run:
      - require:
        - cmd: spinnaker
      - watch:
        - file:  /srv/kubernetes/manifests/spinnaker-ingress.yaml
      - runas: root
      - name: kubectl apply -f /srv/kubernetes/manifests/spinnaker-ingress.yaml