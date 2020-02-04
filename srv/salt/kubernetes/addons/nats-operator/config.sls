# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import nats_operator with context %}

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
    - source: salt://{{ tpldir }}/files/00-prereqs.yaml
    - skip_verify: true
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/nats-operator/nats-operator-deployment.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nats-operator
    - source: salt://{{ tpldir }}/templates/nats-operator-deployment.yaml.j2
    - template: jinja
    - skip_verify: true
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/nats-operator/cluster.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nats-operator
    - source: salt://{{ tpldir }}/files/cluster.yaml
    - skip_verify: true
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/nats-operator/default-rbac.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nats-operator
    - source: salt://{{ tpldir }}/files/default-rbac.yaml
    - skip_verify: true
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/nats-operator/nats-streaming-operator-deployment.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nats-operator
    - source: salt://{{ tpldir }}/templates/nats-streaming-operator-deployment.yaml.j2
    - template: jinja
    - skip_verify: true
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/nats-operator/streaming-cluster.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nats-operator
    - source: salt://{{ tpldir }}/files/streaming-cluster.yaml
    - skip_verify: true
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

{% if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/nats-operator/nats-servicemonitor.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nats-operator
    - source: salt://{{ tpldir }}/files/nats-servicemonitor.yaml
    - skip_verify: true
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
{% endif %}