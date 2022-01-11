# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import envoy with context %}

{% set repoState = 'absent' %}
{% if envoy.enabled %}
  {% set repoState = 'managed' %}
{% endif %}

{%- if grains['os']|lower in ('ubuntu',) %}
{% set url = 'https://deb.dl.getenvoy.io/public/deb/ubuntu ' ~ grains["oscodename"] ~ ' main' %}

envoy-package-repository:
  file.managed:
    - name: /tmp/envoy_repo_key.sh
    - source: salt://{{ tpldir }}/scripts/envoy_repo_key.sh
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  cmd.script:
    - name: repository key
    - source: /tmp/envoy_repo_key.sh
    - context:
        tpldir: {{ tpldir }}
  pkgrepo.{{ repoState }}:
    - humanname: {{ grains["os"] }} {{ grains["oscodename"] | capitalize }} Envoy Proxy Package Repository
    - name: deb [arch={{ grains["osarch"] }} signed-by=/usr/share/keyrings/getenvoy-keyring.gpg] {{ url }}
    - file: /etc/apt/sources.list.d/envoy.list
    {%- if grains['saltversioninfo'] >= [2018, 3, 0] %}
    - refresh: True
    {%- else %}
    - refresh_db: True
    {%- endif %}

{%- elif grains['os_family']|lower in ('redhat',) %}
{% set url = 'https://getenvoy.io/linux/rhel/tetrate-getenvoy.repo' %}

envoy-package-repository:
  pkgrepo.{{ repoState }}:
    - name: kubernetes
    - humanname: {{ grains["os"] }} {{ grains["oscodename"] | capitalize }} Envoy Proxy Package Repository
    - base_url: {{ url }}
    - enabled: 1
    - gpgcheck: 0
    - file: envoy.list
    {%- if grains['saltversioninfo'] >= [2018, 3, 0] %}
    - refresh: True
    {%- else %}
    - refresh_db: True
    {%- endif %}

{% endif %}