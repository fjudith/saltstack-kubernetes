# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import velero with context %}
{%- set public_domain = pillar['public-domain'] -%}
{% from "kubernetes/map.jinja" import storage with context %}

query-velero-minio:
  http.wait_for_successful_query:
    - watch:
      - cmd: velero-minio
      - cmd: velero-ingress
    - name: https://{{ velero.ingress_host }}-minio.{{ public_domain }}/minio/health/ready
    - wait_for: 240
    - request_interval: 5
    - status: 200

velero-minio-bucket:
  cmd.run:
    - require:
      - http: query-velero-minio
    - runas: root
    - timeout: 180
    - env:
      - MC_HOST_velero: "https://{{ velero.s3.accesskey }}:{{ velero.s3.secretkey }}@{{ velero.ingress_host }}-minio.{{ public_domain }}"
    - name: |
        /usr/local/bin/mc mb velero/{{ velero.s3.bucket }} --ignore-existing

velero-backup-test:
  cmd.run:
    - require:
      - cmd: velero-minio-bucket
    - runas: root
    - cwd: /opt/velero-linux-amd64-v{{ velero.version }}/velero-v{{ velero.version }}-linux-amd64
    - timeout: 180
    - name: |
        kubectl apply -f examples/nginx-app/with-pv.yaml

        until kubectl -n nginx-example get deployment nginx-deployment ; do printf '.' && sleep 5 ; done
        echo "" && \
        REPLICAS=$(kubectl -n nginx-example get deployment nginx-deployment -o jsonpath='{.status.replicas}') && \
        echo "Waiting for nginx-deployment to be up and running" && \
        while [ "$(kubectl -n nginx-example get deployment nginx-deployment -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \
        kubectl -n nginx-example get deployment nginx-deployment
        
        velero backup create nginx-backup --selector app=nginx --wait
        velero backup describe nginx-backup
        velero backup logs nginx-backup
        velero backup get

{%- if storage.get('portworx', {'enabled': False}).enabled %}
velero-portworx-test:
  cmd.run:
    - require:
      - cmd: velero-backup-test
    - runas: root
    - timeout: 180
    - name: |
        velero snapshot-location create portworx-local --provider portworx.io/portworx
        velero backup create nginx-backup-portworx \
        --include-namespaces=nginx-example \
        --snapshot-volumes \
        --volume-snapshot-locations portworx-local \
        --selector app=nginx --wait
{%- endif %}

    
    
