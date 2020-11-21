gitea-minio:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/gitea
    - name: /srv/kubernetes/manifests/gitea/minioinstance.yaml
    - source: salt://{{ tpldir }}/templates/minioinstance.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/gitea/minioinstance.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/gitea/minioinstance.yaml

gitea-minio-wait:
  cmd.run:
    - require:
      - cmd: gitea-minio
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n gitea get statefulset minio; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n gitea get statefulset minio -o jsonpath='{.status.replicas}') && \
        
        echo "Waiting for minio to be up and running" && \
        
        while [ "$(kubectl -n gitea get statefulset minio -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n gitea get statefulset minio