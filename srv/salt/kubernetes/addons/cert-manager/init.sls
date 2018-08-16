{%- from "kubernetes/map.jinja" import common with context -%}

addon-cert-manager:
  git.latest:
    - name: https://github.com/jetstack/cert-manager
    - target: /srv/kubernetes/manifests/cert-manager
    - force_reset: True
    - rev: v0.4.0

/srv/kubernetes/manifests/cert-manager/clusterissuer.yaml:
  file.managed:
    - require:
      - git: addon-cert-manager
    - watch:
      - git: addon-cert-manager
    - source: salt://kubernetes/addons/cert-manager/{{ common.addons.cert_manager.dns.provider }}/clusterissuer.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/cert-manager/certificate.yaml:
  file.managed:
    - watch:
      - git: addon-cert-manager
    - source: salt://kubernetes/addons/cert-manager/certificate.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-cert-manager-install:
  cmd.run:
    - require:
      - cmd: kubernetes-wait
    - watch:
        - git:  addon-cert-manager
        - file: /srv/kubernetes/manifests/cert-manager/clusterissuer.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/cert-manager/contrib/manifests/cert-manager/with-rbac.yaml
        kubectl -n cert-manager delete secret public-dns-secret
        kubectl -n cert-manager create secret generic public-dns-secret --from-literal=secret-access-key="{{ common.addons.cert_manager.dns.secret }}"
        kubectl apply -f /srv/kubernetes/manifests/cert-manager/clusterissuer.yaml
        kubectl apply -f /srv/kubernetes/manifests/cert-manager/certificate.yaml
