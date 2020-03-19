kubernetes-dashboard:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard/00_dashboard-namespace.yaml
      - file: /srv/kubernetes/manifests/kubernetes-dashboard/01_dashboard-serviceaccount.yaml
      - file: /srv/kubernetes/manifests/kubernetes-dashboard/02_dashboard-service.yaml
      - file: /srv/kubernetes/manifests/kubernetes-dashboard/03_dashboard-secret.yaml
      - file: /srv/kubernetes/manifests/kubernetes-dashboard/04_dashboard-configmap.yaml
      - file: /srv/kubernetes/manifests/kubernetes-dashboard/05_dashboard-rbac.yaml
      - file: /srv/kubernetes/manifests/kubernetes-dashboard/06_dashboard-deployment.yaml
      - file: /srv/kubernetes/manifests/kubernetes-dashboard/07_scraper-service.yaml
      - file: /srv/kubernetes/manifests/kubernetes-dashboard/08_scraper-deployment.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kubernetes-dashboard/
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'