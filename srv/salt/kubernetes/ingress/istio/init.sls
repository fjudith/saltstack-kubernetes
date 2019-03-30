{%- from "kubernetes/map.jinja" import common with context -%}


/tmp/istio:
  archive.extracted:
    - source: https://github.com/istio/istio/releases/download/{{ common.addons.istio.version }}/istio-{{ common.addons.istio.version }}-linux.tar.gz
    - skip_verify: true
    - user: root
    - group: root
    - archive_format: tar

/usr/local/bin/istioctl:
  file.copy:
    - source: /tmp/istio/istio-{{ common.addons.istio.version }}/bin/istioctl
    - mode: 555
    - user: root
    - group: root
    - force: true
    - require:
      - archive: /tmp/istio
    - unless: cmp -s /usr/local/bin/istioctl /tmp/istio/istio-{{ common.addons.istio.version }}/bin/istioctl

/srv/kubernetes/manifests/istio:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/istio/crds.yaml:
    require:
    - file: /srv/kubernetes/manifests/istio
    file.managed:
    - source: salt://kubernetes/ingress/istio/files/crds.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/istio/istio.yaml:
    require:
    - file: /srv/kubernetes/manifests/istio
    file.managed:
    - source: salt://kubernetes/ingress/istio/files/istio.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/istio/gateway.yaml:
    require:
    - file: /srv/kubernetes/manifests/istio
    file.managed:
    - source: salt://kubernetes/ingress/istio/templates/gateway.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/istio/ingress.yaml:
    require:
    - file: /srv/kubernetes/manifests/istio
    file.managed:
    - source: salt://kubernetes/ingress/istio/templates/ingress.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-istio-install:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/istio/crds.yaml
      - /srv/kubernetes/manifests/istio/istio.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/istio/crds.yaml
        kubectl apply -f /srv/kubernetes/manifests/istio/istio.yaml
        kubectl apply -f /srv/kubernetes/manifests/istio/gateway.yaml
        kubectl apply -f /srv/kubernetes/manifests/istio/ingress.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
