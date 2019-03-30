{%- from "kubernetes/map.jinja" import common with context -%}


/srv/kubernetes/manifests/istio:
  archive.extracted:
    - source: https://github.com/istio/istio/releases/download/{{ common.addons.istio.version }}/istio-{{ common.addons.istio.version }}-linux.tar.gz
    - skip_verify: true
    - user: root
    - group: root
    - archive_format: tar

/srv/kubernetes/manifests/istio/istio-{{ common.addons.istio.version }}/install/kubernetes/helm/:
  archive.extracted:
    - watch:
      - archive: /srv/kubernetes/manifests/istio
    - source: /srv/kubernetes/manifests/istio/istio-{{ common.addons.istio.version }}/install/kubernetes/helm/charts/istio-cni-{{ common.addons.istio.cni_version }}.tgz
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

kubernetes-istio-namespace:
  cmd.run:
    - unless: kubectl get namespace istio-system
    - name: |
        kubectl create namespace istio-system

kubernetes-istio-install:
  cmd.run: 
    - cwd: /srv/kubernetes/manifests/istio/istio-{{ common.addons.istio.version }}
    - whatch:
      - cmd: kubernetes-istio-namespace 
      - archive: /srv/kubernetes/manifests/istio/istio-{{ common.addons.istio.version }}/install/kubernetes/helm/
    - name: |
        helm template install/kubernetes/helm/istio-cni \
          --name=istio-cni \
          --set tracing.enabled=true \
          --namespace=istio-system | kubectl apply -f -

kubernetes-istio-gateway-install:
  cmd.run:
    - watch:
      - cmd: kubernetes-istio-install
    - name: | 
        kubectl apply -f /srv/kubernetes/manifests/istio/gateway.yaml
        kubectl apply -f /srv/kubernetes/manifests/istio/ingress.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
