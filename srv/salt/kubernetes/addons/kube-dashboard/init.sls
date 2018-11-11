{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/kube-dashboard.yaml:
    file.managed:
    - source: salt://kubernetes/addons/kube-dashboard/templates/kube-dashboard.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-dashboard-install:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/kube-dashboard.yaml
    - name: |
        if ! curl --silent http://127.0.0.1:8080/api/v1/namespaces/kube-system/secrets | grep kubernetes-dashboard-certs ; then kubectl --namespace kube-system create secret generic kubernetes-dashboard-certs --from-file=/etc/kubernetes/ssl/dashboard-key.pem --from-file=/etc/kubernetes/ssl/dashboard.pem; fi
        kubectl apply -f /srv/kubernetes/manifests/kube-dashboard.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'