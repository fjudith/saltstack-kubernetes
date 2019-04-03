{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/kubernetes-dashboard:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/kubernetes-dashboard/deployment.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://kubernetes/addons/kubernetes-dashboard/templates/deployment.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kubernetes-dashboard/ingress.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - source: salt://kubernetes/addons/kubernetes-dashboard/templates/ingress.yaml.jinja
    - user: root
    - group: root
    - template: jinja
    - mode: 644

kubernetes-dashboard-install:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/kubernetes-dashboard/deployment.yaml
      - /srv/kubernetes/manifests/kubernetes-dashboard/ingress.yaml
    - name: |
        if ! curl --silent http://127.0.0.1:8080/api/v1/namespaces/kube-system/secrets | grep kubernetes-dashboard-certs ; then kubectl --namespace kube-system create secret generic kubernetes-dashboard-certs --from-file=/etc/kubernetes/ssl/dashboard-key.pem --from-file=/etc/kubernetes/ssl/dashboard.pem; fi
        kubectl apply -f /srv/kubernetes/manifests/kubernetes-dashboard/deployment.yaml
        kubectl apply -f /srv/kubernetes/manifests/kubernetes-dashboard/ingress.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'