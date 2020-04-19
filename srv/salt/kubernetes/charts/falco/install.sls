# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import falco with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- from "kubernetes/map.jinja" import storage with context -%}

/srv/kubernetes/manifests/falco/ca.key:
  x509.private_key_managed:
    - bits: 4096
    - new: True
    {% if salt['file.file_exists']('/srv/kubernetes/manifests/falco/ca.key') -%}
    - prereq:
      - x509: /srv/kubernetes/manifests/falco/ca.crt
    {%- endif %}

/srv/kubernetes/manifests/falco/server.key:
  x509.private_key_managed:
    - bits: 4096
    - new: True
    {% if salt['file.file_exists']('/srv/kubernetes/manifests/falco/server.key') -%}
    - prereq:
      - x509: /srv/kubernetes/manifests/falco/server.crt
    {%- endif %}

/srv/kubernetes/manifests/falco/client.key:
  x509.private_key_managed:
    - bits: 4096
    - new: True
    {% if salt['file.file_exists']('/srv/kubernetes/manifests/falco/client.key') -%}
    - prereq:
      - x509: /srv/kubernetes/manifests/falco/client.crt
    {%- endif %}

/srv/kubernetes/manifests/falco/ca.crt:
  x509.certificate_managed:
    - signing_private_key: /srv/kubernetes/manifests/falco/ca.key
    - CN: "Falco Root CA"
    - O: kubernetes
    - OU: falco
    - basicConstraints: "critical CA:true"
    - keyUsage: "critical cRLSign, keyCertSign"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: 3650
    - days_remaining: 0
    - backup: True
    - managed_private_key:
        name: /srv/kubernetes/manifests/falco/ca.key
        bits: 4096
        backup: True
    - require:
      - file: /srv/kubernetes/manifests/falco

/srv/kubernetes/manifests/falco/server.crt:
  x509.certificate_managed:
    - signing_private_key: /srv/kubernetes/manifests/falco/ca.key
    - signing_cert: /srv/kubernetes/manifests/falco/ca.crt
    - CN: falco-grpc.falco.svc.cluster.local
    - O: kubernetes
    - OU: falco-grpc
    - basicConstraints: "critical CA:false"
    - keyUsage: "critical, nonRepudiation, digitalSignature, keyEncipherment, keyAgreement"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: 3650
    - days_remaining: 0
    - backup: True
    - managed_private_key:
        name: /srv/kubernetes/manifests/falco/server.key
        bits: 4096
        backup: True
    - require:
      - file: /srv/kubernetes/manifests/falco

/srv/kubernetes/manifests/falco/client.crt:
  x509.certificate_managed:
    - signing_private_key: /srv/kubernetes/manifests/falco/ca.key
    - signing_cert: /srv/kubernetes/manifests/falco/ca.crt
    - CN: localhost
    - O: kubernetes
    - OU: falco-exporter
    - basicConstraints: "critical CA:false"
    - keyUsage: "critical, nonRepudiation, digitalSignature, keyEncipherment"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: 3650
    - days_remaining: 0
    - backup: True
    - managed_private_key:
        name: /srv/kubernetes/manifests/falco/client.key
        bits: 4096
        backup: True
    - require:
      - file: /srv/kubernetes/manifests/falco    

falco:
  cmd.run:
    - runas: root
    - watch:
      - x509: /srv/kubernetes/manifests/falco/server.key
      - x509: /srv/kubernetes/manifests/falco/server.crt
      - x509: /srv/kubernetes/manifests/falco/ca.crt
      - file: /srv/kubernetes/manifests/falco/values.yaml
      - cmd: falco-namespace
      - cmd: falco-fetch-charts
    - cwd: /srv/kubernetes/manifests/falco/falco
    - name: |
        helm repo update && \
        helm upgrade --install falco --namespace falco \
            --set-file certs.server.key=/srv/kubernetes/manifests/falco/server.key \
            --set-file certs.server.crt=/srv/kubernetes/manifests/falco/server.crt \
            --set-file certs.ca.crt=/srv/kubernetes/manifests/falco/ca.crt \
            --values=/srv/kubernetes/manifests/falco/values.yaml \
            "./" --wait --timeout 5m

falco-exporter:
  cmd.run:
    - runas: root
    - watch:
      - x509: /srv/kubernetes/manifests/falco/client.key
      - x509: /srv/kubernetes/manifests/falco/client.crt
      - x509: /srv/kubernetes/manifests/falco/ca.crt
      - file: /srv/kubernetes/manifests/falco/exporter-values.yaml
      - cmd: falco-namespace
      - git: falco-exporter-fetch-charts
    - cwd: /srv/kubernetes/manifests/falco/falco-exporter/deploy/helm/falco-exporter
    - name: |
        helm repo update && \
        helm upgrade --install falco-exporter --namespace falco \
            --set-file certs.client.key=/srv/kubernetes/manifests/falco/client.key \
            --set-file certs.client.crt=/srv/kubernetes/manifests/falco/client.crt \
            --set-file certs.ca.crt=/srv/kubernetes/manifests/falco/ca.crt \
            --values=/srv/kubernetes/manifests/falco/exporter-values.yaml \
            "./" --wait --timeout 2m