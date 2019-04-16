{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/knative:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/knative/knative.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/knative
    - source: https://github.com/knative/serving/releases/download/v{{ common.addons.knative.version }}/release.yaml
    - skip_verify: true
    - user: root
    {# - template: jinja #}
    - group: root
    - mode: 644

kubernetes-knative-install:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/knative/knative.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl label namespace default istio-injection=enabled --overwrite
        kubectl apply -f /srv/kubernetes/manifests/knative/knative.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
