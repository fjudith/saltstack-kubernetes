helm-stable-repo:
  cmd.run:
    - name: | 
        helm repo add stable https://charts.helm.sh/stable
        /usr/local/bin/helm repo update
    - require:
      - file: /usr/local/bin/helm