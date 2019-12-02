# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{%- from tpldir ~ "/map.jinja" import kubeadm with context %}

{% set repoState = 'absent' %}
{% if kubeadm.enabled %}
  {% set repoState = 'installed' %}
{% endif %}

kubectl:
  pkg.{{ repoState }}:
    - version: {{ kubeadm.kubernetesVersion }}-00

kubelet:
  pkg.{{ repoState }}:
    - version: {{ kubeadm.kubernetesVersion }}-00

kubeadm:
  pkg.{{ repoState }}:
    - version: {{ kubeadm.kubernetesVersion }}-00