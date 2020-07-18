{%- set hostname = salt['grains.get']('fqdn') -%}
{%- set controlPlaneInterface = pillar['controlPlaneInterface'] -%}
{%- set localIpAddress = salt['network.ip_addrs'](controlPlaneInterface) -%}

/etc/etcd/pki/ca.key:
  x509.private_key_managed:
    - bits: 4096
    - new: True
    - cipher: des_ede3_cbc
    {% if salt['file.file_exists']('/etc/etcd/pki/ca.key') -%}
    - prereq:
      - x509: /etc/etcd/pki/ca.crt
    {%- endif %}

/etc/etcd/pki/ca.crt:
  x509.certificate_managed:
    - signing_private_key: /etc/etcd/pki/ca.key
    - CN: "Etcd Root CA"
    - O: kubernetes
    - OU: etcd
    - basicConstraints: "critical CA:true"
    - keyUsage: "critical cRLSign, keyCertSign"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: 3650
    - days_remaining: 30
    - backup: True
    - require:
      - file: /etc/etcd/pki

send-etcd-ca-certificate:
  module.run:
    - mine.send:
      - name: x509.get_pem_entries 
      - glob_path: /etc/etcd/pki/ca.*
    - watch:
      - x509: /etc/etcd/pki/ca.crt
      - x509: /etc/etcd/pki/ca.key

/etc/etcd/pki/server.key:
  x509.private_key_managed:
    - bits: 4096
    - new: True
    - cipher: des_ede3_cbc
    {% if salt['file.file_exists']('/etc/etcd/pki/server.key') -%}
    - prereq:
      - x509: /etc/etcd/pki/server.crt
    {%- endif %}

/etc/etcd/pki/server.crt:
  x509.certificate_managed:
    - public_key: /etc/etcd/pki/server.key
    - signing_private_key: /etc/etcd/pki/ca.key
    - signing_cert: /etc/etcd/pki/ca.crt
    - CN: {{ hostname }}
    - O: kubernetes
    - OU: etcd
    - basicConstraints: "critical CA:false"
    - keyUsage: "Digital Signature, Key Encipherment"
    - extendedKeyUsage: "TLS Web Server Authentication, TLS Web Client Authentication"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: 3649
    - days_remaining: 30
    - backup: True
    - subjectAltName: 'IP:127.0.0.1, DNS:{{ hostname }}, IP:{{ localIpAddress[0] }}'
    - require:
      - x509: /etc/etcd/pki/ca.key
      - x509: /etc/etcd/pki/ca.crt

/etc/etcd/pki/peer.key:
  x509.private_key_managed:
    - bits: 4096
    - new: True
    - cipher: des_ede3_cbc
    {% if salt['file.file_exists']('/etc/etcd/pki/peer.key') -%}
    - prereq:
      - x509: /etc/etcd/pki/peer.crt
    {%- endif %}

/etc/etcd/pki/peer.crt:
  x509.certificate_managed:
    - public_key: /etc/etcd/pki/peer.key
    - signing_private_key: /etc/etcd/pki/ca.key
    - signing_cert: /etc/etcd/pki/ca.crt
    - CN: {{ hostname }}
    - O: kubernetes
    - OU: etcd
    - basicConstraints: "critical CA:false"
    - keyUsage: "Digital Signature, Key Encipherment"
    - extendedKeyUsage: "TLS Web Server Authentication, TLS Web Client Authentication"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: 3649
    - days_remaining: 30
    - backup: True
    - subjectAltName: 'IP:{{ localIpAddress[0] }}'
    - require:
      - x509: /etc/etcd/pki/ca.key
      - x509: /etc/etcd/pki/ca.crt

/etc/etcd/pki/etcdctl-etcd-client.key:
  x509.private_key_managed:
    - bits: 4096
    - new: True
    - cipher: des_ede3_cbc
    {% if salt['file.file_exists']('/etc/etcd/pki/etcdctl-etcd-client.key') -%}
    - prereq:
      - x509: /etc/etcd/pki/etcdctl-etcd-client.crt
    {%- endif %}

/etc/etcd/pki/etcdctl-etcd-client.crt:
  x509.certificate_managed:
    - public_key: /etc/etcd/pki/etcdctl-etcd-client.key
    - signing_private_key: /etc/etcd/pki/ca.key
    - signing_cert: /etc/etcd/pki/ca.crt
    - CN: {{ hostname }}
    - O: kubernetes
    - OU: etcd
    - basicConstraints: "critical CA:false"
    - keyUsage: "Digital Signature, Key Encipherment"
    - extendedKeyUsage: "TLS Web Client Authentication"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: 3649
    - days_remaining: 30
    - backup: True
    - subjectAltName: 'IP:127.0.0.1, IP:{{ localIpAddress[0] }}'
    - require:
      - x509: /etc/etcd/pki/ca.key
      - x509: /etc/etcd/pki/ca.crt  