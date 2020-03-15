/srv/kubernetes/manifests/openfaas:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/openfaas/values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/openfaas
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/openfaas/secrets.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/openfaas
    - source: salt://{{ tpldir }}/templates/secrets.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/openfaas/nats-connector-deployment.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/openfaas
    - source: salt://{{ tpldir }}/templates/nats-connector-deployment.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}