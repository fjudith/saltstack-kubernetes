# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import cert_manager with context %}

{% set state = 'absent' %}
{% set file_state = 'absent' %}
{% if cert_manager.enabled %}
  {% set state = 'present' %}
  {% set file_state = 'managed' %}
{% endif %}

cert-manager-crds:
  file.{{ file_state }}:
    - require:
      - file: /srv/kubernetes/manifests/cert-manager
    - name: /srv/kubernetes/manifests/cert-manager/cert-manager.crds.yaml
    - source: https://github.com/jetstack/cert-manager/releases/download/v{{ cert_manager.version }}/cert-manager.crds.yaml
    - user: root
    - group: root
    - mode: "0644"
    - skip_verify: true
  cmd.run:
    - onchanges:
        - file: /srv/kubernetes/manifests/cert-manager/cert-manager.crds.yaml
    - runas: root
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: kubectl apply -f /srv/kubernetes/manifests/cert-manager/cert-manager.crds.yaml

cert-manager:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/cert-manager
    - name: /srv/kubernetes/charts/cert-manager/values.yaml
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - watch:
      - file: /srv/kubernetes/charts/cert-manager/values.yaml
    - name: cert-manager
    {%- if cert_manager.enabled %}
    - chart: jetstack/cert-manager
    - values: /srv/kubernetes/charts/cert-manager/values.yaml
    - version: {{ cert_manager.chart_version }}
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: cert-manager
    - require_in:
      - cmd: cert-manager-wait-api
      - cmd: cert-manager-clusterissuer

{% if cert_manager.get('dns', {'enabled': False}).enabled and cert_manager.dns.provider == 'cloudflare'%}
cert-manager-cloudflare-secret:
  file.{{ file_state }}:
    - require:
      - helm: cert-manager
      - file:  /srv/kubernetes/manifests/cert-manager
    - name: /srv/kubernetes/manifests/cert-manager/cloudflare.yaml
    - source: salt://{{ tpldir }}/templates/cloudflare.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/cert-manager/cloudflare.yaml
{% endif %}

cert-manager-wait-api:
  cmd.run:
    - name: |
        http --check-status --verify false \
        --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
        --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
        https://localhost:6443/apis/{{ cert_manager.api_version }} | grep -niE "{{ cert_manager.api_version }}"
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10

cert-manager-clusterissuer:
  file.{{ file_state }}:
    - require:
      - file: /srv/kubernetes/manifests/cert-manager
    - name: /srv/kubernetes/manifests/cert-manager/clusterissuer.yaml
    - source: salt://{{ tpldir }}/templates/clusterissuer.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: cert-manager-wait-api
    - whatch:
        - file: /srv/kubernetes/manifests/cert-manager/clusterissuer.yaml
    - runas: root
    - onlyif: |
        http --check-status --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/cert-manager.io
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/cert-manager/clusterissuer.yaml
