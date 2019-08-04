{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/kubernetes-dashboard:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/kubernetes-dashboard/00_dashboard-namespace.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://kubernetes/addons/kubernetes-dashboard/files/dashboard-namespace.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kubernetes-dashboard/01_dashboard-serviceaccount.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://kubernetes/addons/kubernetes-dashboard/files/dashboard-serviceaccount.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kubernetes-dashboard/02_dashboard-service.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://kubernetes/addons/kubernetes-dashboard/files/dashboard-service.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kubernetes-dashboard/03_dashboard-secret.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://kubernetes/addons/kubernetes-dashboard/files/dashboard-secret.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kubernetes-dashboard/04_dashboard-configmap.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://kubernetes/addons/kubernetes-dashboard/files/dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kubernetes-dashboard/05_dashboard-rbac.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://kubernetes/addons/kubernetes-dashboard/files/dashboard-rbac.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kubernetes-dashboard/06_dashboard-deployment.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://kubernetes/addons/kubernetes-dashboard/templates/dashboard-deployment.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kubernetes-dashboard/07_scraper-service.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://kubernetes/addons/kubernetes-dashboard/files/scraper-service.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kubernetes-dashboard/08_scraper-deployment.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://kubernetes/addons/kubernetes-dashboard/templates/scraper-deployment.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kubernetes-dashboard/09_dashboard-ingress.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://kubernetes/addons/kubernetes-dashboard/templates/dashboard-ingress.yaml.j2
    - user: root
    - group: root
    - template: jinja
    - mode: 644

kubernetes-dashboard-install:
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
      - file: /srv/kubernetes/manifests/kubernetes-dashboard/09_dashboard-ingress.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kubernetes-dashboard/
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

kubernetes-dashboard-wait:
  cmd.run:
    - require:
      - cmd: kubernetes-dashboard-install
    - runas: root
    - name: |
        until kubectl -n kubernetes-dashboard get pods --field-selector=status.phase=Running --selector=k8s-app=kubernetes-dashboard; do printf 'kubernetes-dashboard is not Running' && sleep 5; done
        until kubectl -n kubernetes-dashboard get pods --field-selector=status.phase=Running --selector=k8s-app=dashboard-metrics-scraper; do printf 'dashboard-metrics-scraper is not Running' && sleep 5; done
    - use_vt: True
    - timeout: 180