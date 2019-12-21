/srv/kubernetes/manifests/proxyinjector:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/proxyinjector/values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/proxyinjector
    - source: salt://kubernetes/charts/proxyinjector/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: 755
    - template: jinja

/srv/kubernetes/manifests/proxyinjector/demo-values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/proxyinjector
    - source: salt://kubernetes/charts/proxyinjector/templates/demo-values.yaml.j2
    - user: root
    - group: root
    - mode: 755
    - template: jinja