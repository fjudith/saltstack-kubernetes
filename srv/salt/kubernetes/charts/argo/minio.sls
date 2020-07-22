argo-minio:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/argo
    - name: /srv/kubernetes/manifests/argo/minioinstance.yaml
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
      - file: /srv/kubernetes/manifests/argo/minioinstance.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/argo/minioinstance.yaml

argo-minio-wait:
  cmd.run:
    - require:
      - cmd: argo-minio
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n argo get statefulset minio; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n argo get statefulset minio -o jsonpath='{.status.replicas}') && \
        
        echo "Waiting for minio to be up and running" && \
        
        while [ "$(kubectl -n argo get statefulset minio -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n argo get statefulset minio