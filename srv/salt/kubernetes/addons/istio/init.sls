{%- from "kubernetes/map.jinja" import common with context -%}


/tmp/istio:
  archive.extracted:
    - source: https://github.com/istio/istio/releases/download/{{ common.addons.ingress_istio.version }}/istio-{{ common.addons.ingress_istio.version }}-linux.tar.gz
    - skip_verify: true
    - user: root
    - group: root
    - archive_format: tar

/usr/local/bin/istioctl:
  file.copy:
    - source: /tmp/istio/istio-{{ common.addons.ingress_istio.version }}/bin/istioctl
    - mode: 555
    - user: root
    - group: root
    - force: true
    - require:
      - archive: /tmp/istio
    - unless: cmp -s /usr/local/bin/istioctl /tmp/istio/istio-{{ common.addons.ingress_istio.version }}/bin/istioctl

/srv/kubernetes/manifests/istio:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/istio/monitoring:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/istio/crds.yaml:
    require:
    - file: /srv/kubernetes/manifests/istio
    file.managed:
    - source: salt://kubernetes/addons/istio/crds.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/istio/istio.yaml:
    require:
    - file: /srv/kubernetes/manifests/istio
    file.managed:
    - source: salt://kubernetes/addons/istio/istio.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/istio/gateway.yaml:
    require:
    - file: /srv/kubernetes/manifests/istio
    file.managed:
    - source: salt://kubernetes/addons/istio/gateway.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/istio/monitoring/istio-dashboard.yaml:
    require:
    - file: /srv/kubernetes/manifests/istio/monitoring
    file.managed:
    - source: salt://kubernetes/addons/istio/monitoring/istio-dashboard.yaml
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
        kubectl apply -f /srv/kubernetes/manifests/istio/monitoring/istio-dashboard.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
