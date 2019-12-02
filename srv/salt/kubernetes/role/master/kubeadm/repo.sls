# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{%- from tpldir ~ "/map.jinja" import kubeadm with context %}

{% set repoState = 'absent' %}
{% if kubeadm.enabled %}
  {% set repoState = 'managed' %}
{% endif %}

{%- if grains['os_family']|lower in ('debian',) %}
  {%- if grains['os']|lower in ('ubuntu',) %}
    {% set url = 'https://apt.kubernetes.io/ ' ~ 'kubernetes' ~ '-' ~ 'xenial' ~ ' main' %}
  {% else %}
    {% set url = 'https://apt.kubernetes.io/ ' ~ 'kubernetes' ~ '-' ~ grains["oscodename"] ~ ' main' %}
  {% endif %}

kubernetes-package-repository:
  pkgrepo.{{ repoState }}:
    - humanname: {{ grains["os"] }} {{ grains["oscodename"] | capitalize }} Kubernetes Package Repository
    - name: deb [arch={{ grains["osarch"] }}] {{ url }}
    - key_url: https://packages.cloud.google.com/apt/doc/apt-key.gpg
    - file: /etc/apt/sources.list.d/kubernetes.list
    {%- if grains['saltversioninfo'] >= [2018, 3, 0] %}
    - refresh: True
        {%- else %}
    - refresh_db: True
        {%- endif %}

{%- elif grains['os_family']|lower in ('redhat',) %}
{% set url = 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64' %}

kubernetes-repo:
  pkgrepo.{{ repoState }}:
    - name: kubernetes
    - humanname: {{ grains["os"] }} {{ grains["oscodename"] | capitalize }} Kubernetes Package Repository
    - base_url: {{ url }}
    - enabled: 1
    - gpgcheck: 1
    - gpgkey: https://packages.cloud.google.com/yum/doc/yum-key.gpg
    - file: kubernetes.list
    {%- if grains['saltversioninfo'] >= [2018, 3, 0] %}
    - refresh: True
        {%- else %}
    - refresh_db: True
        {%- endif %}

{% endif %}