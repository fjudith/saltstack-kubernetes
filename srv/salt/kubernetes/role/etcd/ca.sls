{%- set hostname = salt['grains.get']('fqdn') -%}
{%- set controlPlaneInterface = pillar['controlPlaneInterface'] -%}
{%- set localIpAddress = salt['network.ip_addrs'](controlPlaneInterface) -%}

/etc/etcd/pki:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/etc/etcd/pki/ca.key:
  x509.private_key_managed:
    - require:
      - file: /etc/etcd/pki
    - bits: 4096
    - new: true
    - cipher: des_ede3_cbc
    - unless: test -f /etc/etcd/pki/ca.key

/etc/etcd/pki/ca.crt:
  file.absent:
    - onchanges:
      - x509: /etc/etcd/pki/ca.key
  x509.certificate_managed:
    - require:
      - x509: /etc/etcd/pki/ca.key
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
    - unless: test -f /etc/etcd/pki/ca.crt
    

send-etcd-ca-certificate:
  module.run:
    - mine.send:
      - name: x509.get_pem_entries 
      - glob_path: /etc/etcd/pki/ca.*
    - onchanges:
      - x509: /etc/etcd/pki/ca.crt
      - x509: /etc/etcd/pki/ca.key
