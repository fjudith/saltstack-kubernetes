/srv/kubernetes/manifests/proxyinjector:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/proxyinjector/values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/proxyinjector
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/proxyinjector/kubehttpbin-values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/proxyinjector
    - source: salt://{{ tpldir }}/templates/kubehttpbin-values.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}