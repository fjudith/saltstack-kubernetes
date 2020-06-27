argo-teardown:
  cmd.run:
    - runas: root
    - group: root
    - name: |
        helm delete -n argo argo
        kubectl delete crd nucliofunctionevents.nuclio.io
        kubectl delete crd nucliofunctions.nuclio.io
        kubectl delete crd nuclioprojects.nuclio.io
        kubectl -n nuclio delete secret registry-harbor-local
        kubectl -n nuclio delete secret registry-docker-hub
        kubectl -n nuclio delete secret registry-quay
        kubectl -n nuclio delete secret registy-harbor
        
