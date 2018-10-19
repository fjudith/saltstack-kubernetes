{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/kubeless:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/kubeless/namespace.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubeless
    - source: salt://kubernetes/addons/kubeless/namespace.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kubeless/kubeless.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubeless
    - source: https://github.com/kubeless/kubeless/releases/download/{{ common.addons.kubeless.version }}/kubeless-{{ common.addons.kubeless.version }}.yaml
    - skip_verify: true
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kubeless/kubeless-ui.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubeless
    - source: https://raw.githubusercontent.com/kubeless/kubeless-ui/{{ common.addons.kubeless.ui_version }}/k8s.yaml
    - skip_verify: true
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/tmp/kubeless-v{{ common.addons.kubeless.version }}:
  archive.extracted:
    - source: https://github.com/kubeless/kubeless/releases/download/{{ common.addons.kubeless.version }}/kubeless_linux-amd64.zip
    - skip_verify: true
    {# - source_hash: {{ common.addons.kubeless.source_hash }} #}
    - user: root
    - group: root
    - archive_format: zip
    - enforce_toplevel: false

/usr/local/bin/kubeless:
  file.copy:
    - source: /tmp/kubeless-v{{ common.addons.kubeless.version }}/bundles/kubeless_linux-amd64/kubeless
    - mode: 555
    - user: root
    - group: root
    - force: true
    - require:
      - archive: /tmp/kubeless-v{{ common.addons.kubeless.version }}
    - unless: cmp -s /usr/local/bin/kubeless /tmp/kubeless-v{{ common.addons.kubeless.version }}/bundles/kubeless_linux-amd64/kubeless

kubernetes-kubeless-install:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/kubeless/namespace.yaml
        - file: /srv/kubernetes/manifests/kubeless/kubeless.yaml
        - file: /srv/kubernetes/manifests/kubeless/kubeless-ui.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kubeless/namespace.yaml
        kubectl apply -f /srv/kubernetes/manifests/kubeless/kubeless.yaml
        kubectl apply -f /srv/kubernetes/manifests/kubeless/kubeless-ui.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'

{% if common.addons.get('ingress_istio', {'enabled': False}).enabled -%}
/srv/kubernetes/manifests/kubeless/virtualservice.yaml:
    require:
    - file: /srv/kubernetes/manifests/kubeless
    file.managed:
    - source: salt://kubernetes/addons/kubeless/virtualservice.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-kubeless-ingress-install:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/kubeless/virtualservice.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kubeless/virtualservice.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
{% endif %}