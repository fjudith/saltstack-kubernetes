{%- from "kubernetes/map.jinja" import common with context -%}

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
    - require:
      - cmd: kubernetes-wait
    - watch:
      - /srv/kubernetes/manifests/istio/crds.yaml
      - /srv/kubernetes/manifests/istio/istio.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/istio/crds.yaml
        kubectl apply -f /srv/kubernetes/manifests/istio/istio.yaml
        kubectl apply -f /srv/kubernetes/manifests/istio/gateway.yaml
        kubectl apply -f /srv/kubernetes/manifests/istio/monitoring/istio-dashboard.yaml