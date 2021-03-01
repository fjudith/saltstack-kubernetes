# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/weave-scope:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/weave-scope/cluster-role-binding.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://{{ tpldir }}/files/cluster-role-binding.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/weave-scope/cluster-role.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://{{ tpldir }}/files/cluster-role.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/weave-scope/deploy.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://{{ tpldir }}/templates/deploy.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}


{%- if common.cri.provider == 'containerd' %}
/srv/kubernetes/manifests/weave-scope/ds.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://{{ tpldir }}/templates/ds-containerd.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}
{%- elif common.cri.provider == 'crio' %}
/srv/kubernetes/manifests/weave-scope/ds.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://{{ tpldir }}/templates/ds-crio.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}
{%- else%}
/srv/kubernetes/manifests/weave-scope/ds.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://{{ tpldir }}/templates/ds.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}
{%- endif %}

/srv/kubernetes/manifests/weave-scope/probe-deploy.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://{{ tpldir }}/templates/probe-deploy.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/weave-scope/psp.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://{{ tpldir }}/files/psp.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/weave-scope/sa.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://{{ tpldir }}/files/sa.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/weave-scope/svc.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://{{ tpldir }}/files/svc.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}