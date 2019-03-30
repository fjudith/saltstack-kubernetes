{%- from "kubernetes/map.jinja" import common with context -%}


/srv/kubernetes/manifests/istio:
  archive.extracted:
    - source: https://github.com/istio/istio/releases/download/{{ common.addons.istio.version }}/istio-{{ common.addons.istio.version }}-linux.tar.gz
    - skip_verify: true
    - user: root
    - group: root
    - archive_format: tar

/usr/local/bin/istioctl:
  file.copy:
    - source: /srv/kubernetes/manifests/istio/istio-{{ common.addons.istio.version }}/bin/istioctl
    - mode: 555
    - user: root
    - group: root
    - force: true
    - require:
      - archive: /srv/kubernetes/manifests/istio
    - unless: cmp -s /usr/local/bin/istioctl /srv/kubernetes/manifests/istio/istio-{{ common.addons.istio.version }}/bin/istioctl

/srv/kubernetes/manifests/istio/gateway.yaml:
    require:
    - archive: /srv/kubernetes/manifests/istio
    file.managed:
    - source: salt://kubernetes/ingress/istio/templates/gateway.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/istio/ingress.yaml:
    require:
    - archive: /srv/kubernetes/manifests/istio
    file.managed:
    - source: salt://kubernetes/ingress/istio/templates/ingress.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-istio-install:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/istio/istio-{{ common.addons.istio.version }}
    - whatch:
      - archive: /srv/kubernetes/manifests/istio
    - name: |
       for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done
       kubectl apply -f install/kubernetes/istio-demo.yaml

kubernetes-istio-gateway-install:
  cmd.run:
    - watch:
      - cmd: kubernetes-istio-install
    - name: | 
        kubectl apply -f /srv/kubernetes/manifests/istio/gateway.yaml
        kubectl apply -f /srv/kubernetes/manifests/istio/ingress.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
