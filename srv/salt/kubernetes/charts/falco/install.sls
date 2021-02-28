# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import falco with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- from "kubernetes/map.jinja" import storage with context -%}

{# /srv/kubernetes/manifests/falco/certs/ca.key:
  x509.private_key_managed:
    - bits: 4096
    - new: True
    - cipher: des_ede3_cbc
    {% if salt['file.file_exists']('/srv/kubernetes/manifests/falco/certs/ca.key') -%}
    - prereq:
      - x509: /srv/kubernetes/manifests/falco/certs/ca.crt
    {%- endif %}

/srv/kubernetes/manifests/falco/certs/server.key:
  x509.private_key_managed:
    - bits: 4096
    - new: True
    - cipher: des_ede3_cbc
    {% if salt['file.file_exists']('/srv/kubernetes/manifests/falco/certs/server.key') -%}
    - prereq:
      - x509: /srv/kubernetes/manifests/falco/certs/server.crt
    {%- endif %}

/srv/kubernetes/manifests/falco/certs/client.key:
  x509.private_key_managed:
    - bits: 4096
    - new: True
    - cipher: des_ede3_cbc
    {% if salt['file.file_exists']('/srv/kubernetes/manifests/falco/certs/client.key') -%}
    - prereq:
      - x509: /srv/kubernetes/manifests/falco/certs/client.crt
    {%- endif %}

/srv/kubernetes/manifests/falco/certs/ca.crt:
  x509.certificate_managed:
    - signing_private_key: /srv/kubernetes/manifests/falco/certs/ca.key
    - CN: "Falco Root CA"
    - O: kubernetes
    - OU: falco
    - basicConstraints: "critical CA:true"
    - keyUsage: "critical cRLSign, keyCertSign"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: 3650
    - days_remaining: 30
    - backup: True
    - require:
      - file: /srv/kubernetes/manifests/falco/certs

/srv/kubernetes/manifests/falco/certs/server.crt:
  x509.certificate_managed:
    - signing_private_key: /srv/kubernetes/manifests/falco/certs/ca.key
    - signing_cert: /srv/kubernetes/manifests/falco/certs/ca.crt
    - CN: falco-grpc.falco.svc.cluster.local
    - O: kubernetes
    - OU: falco-grpc
    - basicConstraints: "critical CA:false"
    - keyUsage: "critical, nonRepudiation, digitalSignature, keyEncipherment, keyAgreement"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: 3649
    - days_remaining: 30
    - backup: True
    - require:
      - file: /srv/kubernetes/manifests/falco/certs

/srv/kubernetes/manifests/falco/certs/client.crt:
  x509.certificate_managed:
    - signing_private_key: /srv/kubernetes/manifests/falco/certs/ca.key
    - signing_cert: /srv/kubernetes/manifests/falco/certs/ca.crt
    - CN: localhost
    - O: kubernetes
    - OU: falco-exporter
    - basicConstraints: "critical CA:false"
    - keyUsage: "critical, nonRepudiation, digitalSignature, keyEncipherment"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: 3649
    - days_remaining: 30
    - backup: True
    - require:
      - file: /srv/kubernetes/manifests/falco/certs    #}

falco-ca-cert:
  cmd.run:
    - runas: root
    - require:
      - file: /srv/kubernetes/manifests/falco/certs
    - cwd: /srv/kubernetes/manifests/falco/certs
    - name: |
        openssl genrsa -passout pass:1234 -des3 -out ca.key 4096
        openssl req -passin pass:1234 -new -x509 -days 365 -key ca.key -out ca.crt -subj  "/O=kubernetes/OU=falco/CN=Falco Root CA"
    - unless: test -f /srv/kubernetes/manifests/falco/certs/ca.crt

falco-server-cert:
  cmd.run:
    - runas: root
    - require:
      - file: /srv/kubernetes/manifests/falco/certs
    - cwd: /srv/kubernetes/manifests/falco/certs
    - name: |
        openssl genrsa -passout pass:1234 -des3 -out server.key 4096
        openssl req -passin pass:1234 -new -key server.key -out server.csr -subj  "/O=kubernetes/OU=falco-grpc/CN=falco-grpc.falco.svc.cluster.local"
        openssl x509 -req -passin pass:1234 -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt
        openssl rsa -passin pass:1234 -in server.key -out server.key
    - unless: test -f /srv/kubernetes/manifests/falco/certs/server.crt

falco-client-cert:
  cmd.run:
    - runas: root
    - require:
      - file: /srv/kubernetes/manifests/falco/certs
    - cwd: /srv/kubernetes/manifests/falco/certs
    - name: |
        openssl genrsa -passout pass:1234 -des3 -out client.key 4096
        openssl req -passin pass:1234 -new -key client.key -out client.csr -subj  "/O=kubernetes/OU=falco-exporter/CN=localhost"
        openssl x509 -req -passin pass:1234 -days 365 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out client.crt
        openssl rsa -passin pass:1234 -in client.key -out client.key
    - unless: test -f /srv/kubernetes/manifests/falco/certs/client.crt

falco:
  cmd.run:
    - runas: root
    - watch:
      - cmd: falco-ca-cert
      - cmd: falco-server-cert
      - file: /srv/kubernetes/manifests/falco/values.yaml
      - cmd: falco-namespace
      - cmd: falco-fetch-charts
    - cwd: /srv/kubernetes/manifests/falco/falco
    - name: |
        helm repo update && \
        helm upgrade --install falco --namespace falco \
            --set-file certs.server.key=/srv/kubernetes/manifests/falco/certs/server.key \
            --set-file certs.server.crt=/srv/kubernetes/manifests/falco/certs/server.crt \
            --set-file certs.ca.crt=/srv/kubernetes/manifests/falco/certs/ca.crt \
            --values=/srv/kubernetes/manifests/falco/values.yaml \
            "./" --wait --timeout 10m

falco-exporter:
  cmd.run:
    - runas: root
    - watch:
      - cmd: falco-ca-cert
      - cmd: falco-client-cert
      - file: /srv/kubernetes/manifests/falco/exporter-values.yaml
      - cmd: falco-namespace
      - cmd: falco-exporter-fetch-charts
    - cwd: /srv/kubernetes/manifests/falco/falco-exporter
    - name: |
        helm repo update && \
        helm upgrade --install falco-exporter --namespace falco \
            --set-file certs.client.key=/srv/kubernetes/manifests/falco/certs/client.key \
            --set-file certs.client.crt=/srv/kubernetes/manifests/falco/certs/client.crt \
            --set-file certs.ca.crt=/srv/kubernetes/manifests/falco/certs/ca.crt \
            --values=/srv/kubernetes/manifests/falco/exporter-values.yaml \
            "./" --wait --timeout 2m