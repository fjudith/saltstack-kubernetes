helm-stable-repo:
  cmd.run:
    - name: | 
        helm repo add stable https://kubernetes-charts.storage.googleapis.com/
        /usr/local/bin/helm repo update
    - require:
      - file: /usr/local/bin/helm