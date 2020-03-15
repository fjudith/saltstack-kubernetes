# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import kubeless with context %}
{%- from "kubernetes/map.jinja" import common with context %}

/srv/kubernetes/manifests/kubeless:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/kubeless/kubeless-ui.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubeless
    - source: https://raw.githubusercontent.com/kubeless/kubeless-ui/{{ kubeless.ui_version }}/k8s.yaml
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"

/srv/kubernetes/manifests/kubeless/kubeless.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubeless
    - source: https://github.com/kubeless/kubeless/releases/download/v{{ kubeless.version }}/kubeless-v{{ kubeless.version }}.yaml
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"

/srv/kubernetes/manifests/kubeless/kafka-trigger.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubeless
    - source: salt://{{ tpldir }}/templates/kafka-trigger.yaml.j2
    - template: jinja
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/kubeless/kinesis-trigger.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubeless
    - source: salt://{{ tpldir }}/templates/kinesis-trigger.yaml.j2
    - template: jinja
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

{% if common.addons.get('nats_operator', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/kubeless/nats-trigger.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubeless
    - source: salt://{{ tpldir }}/templates/nats-trigger.yaml.j2
    - template: jinja
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/kubeless/test.py:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubeless
    - source: salt://{{ tpldir }}/demo/pubsub-functions/test.py
    - template: jinja
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
{% endif %}