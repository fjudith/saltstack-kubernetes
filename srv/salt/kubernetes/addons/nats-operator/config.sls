{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/nats-operator:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/nats-operator/00-prereqs.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nats-operator
    - source: salt://kubernetes/addons/nats-operator/files/00-prereqs.yaml
    - skip_verify: true
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/nats-operator/10-deployment.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nats-operator
    - source: salt://kubernetes/addons/nats-operator/templates/10-deployment.yaml.j2
    - template: jinja
    - skip_verify: true
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/nats-operator/cluster.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nats-operator
    - source: salt://kubernetes/addons/nats-operator/files/cluster.yaml
    - skip_verify: true
    - user: root
    - group: root
    - mode: 644