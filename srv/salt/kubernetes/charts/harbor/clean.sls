harbor-teardown:
  cmd.run:
    - runas: root
    - group: root
    - name: |
        helm -n harbor delete harbor
        kubectl -n harbor delete pvc -l app=harbor 
        kubectl -n harbor delete minioinstance minio
        kubectl -n harbor delete pvc -l v1beta1.min.io/instance=minio
        kubectl -n harbor delete ing --all
