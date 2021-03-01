# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import mailhog with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

/opt/mailhog-linux-amd64-v{{ mailhog.version }}:
  file.managed:
    - source:  https://github.com/mailhog/MailHog/releases/download/v{{ mailhog.version }}/MailHog_linux_amd64
    - skip_verify: True
    - mode: "0755"
    - user: root
    - group: root
    - if_missing: /opt/mailhog-linux-amd64-v{{ mailhog.version }}

/usr/local/bin/mailhog:
  file.symlink:
    - target: /opt/mailhog-linux-amd64-v{{ mailhog.version }}

mailhog-auth-file:
  cmd.run:
    - require:
      - file: /usr/local/bin/mailhog
    - cwd: /srv/kubernetes/manifests/mailhog
    - runas: root
    - name: |
        rm -f auth.txt
        {%- for item,value in mailhog.users.items() %}
        echo "{{ item }}:$(mailhog bcrypt {{value}})" | tee -a auth.txt
        {%- endfor %}
        kubectl -n mailhog get secret mailhog-users || \
        kubectl -n mailhog create secret generic mailhog-users --from-file=auth.txt=./auth.txt

mailhog:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/mailhog/values.yaml
    - require:
      - cmd: mailhog-fetch-charts
      - cmd: mailhog-namespace
      - cmd: mailhog-auth-file
    - runas: root
    - cwd: /srv/kubernetes/manifests/mailhog/mailhog
    - name: |
        helm upgrade --install mailhog --namespace mailhog \
          --values /srv/kubernetes/manifests/mailhog/values.yaml \
          "./" --wait --timeout 3m