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
    - source: salt://{{ tpldir }}/files/dashboard-namespace.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/kubernetes-dashboard/01_dashboard-serviceaccount.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://{{ tpldir }}/files/dashboard-serviceaccount.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/kubernetes-dashboard/02_dashboard-service.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://{{ tpldir }}/files/dashboard-service.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/kubernetes-dashboard/03_dashboard-secret.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://{{ tpldir }}/files/dashboard-secret.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/kubernetes-dashboard/04_dashboard-configmap.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://{{ tpldir }}/files/dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/kubernetes-dashboard/05_dashboard-rbac.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://{{ tpldir }}/files/dashboard-rbac.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/kubernetes-dashboard/06_dashboard-deployment.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://{{ tpldir }}/templates/dashboard-deployment.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/kubernetes-dashboard/07_scraper-service.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://{{ tpldir }}/files/scraper-service.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/kubernetes-dashboard/08_scraper-deployment.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://{{ tpldir }}/templates/scraper-deployment.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/kubernetes-dashboard/09_dashboard-ingress.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://{{ tpldir }}/templates/dashboard-ingress.yaml.j2
    - user: root
    - group: root
    - template: jinja
    - mode: 644
    - context:
        tpldir: {{ tpldir }}
