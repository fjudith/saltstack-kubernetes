{%- set hostname = salt['grains.get']('fqdn') -%}
{%- set controlPlaneInterface = pillar['controlPlaneInterface'] -%}
{%- set localIpAddress = salt['network.ip_addrs'](controlPlaneInterface) -%}

{%- set etcds = [] -%}
{%- for key, value in salt["mine.get"](tgt="role:etcd", fun="network.get_hostname", tgt_type="grain")|dictsort(false, 'value') -%}
  {%- do etcds.append(value) -%}
{%- endfor -%}

/etc/etcd/pki:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/etc/etcd/pki/ca.crt:
  x509.pem_managed:
    - require:
      - file: /etc/etcd/pki
    - text: {{ salt['mine.get'](tgt=etcds|first, fun='x509.get_pem_entries', tgt_type='glob')[etcds|first]['/etc/etcd/pki/ca.crt']|replace('\n', '') }}
    - backup: True

/etc/etcd/pki/ca.key:
  x509.pem_managed:
    - require:
      - file: /etc/etcd/pki
    - text: {{ salt['mine.get'](tgt=etcds|first, fun='x509.get_pem_entries', tgt_type='glob')[etcds|first]['/etc/etcd/pki/ca.key']|replace('\n', '') }}
    - backup: True

/etc/etcd/pki/kube-apiserver-client.key:
  x509.private_key_managed:
    - bits: 4096
    - new: True
    - cipher: des_ede3_cbc

/etc/etcd/pki/kube-apiserver-client.crt:
  file.absent:
    - onchanges:
      - x509: /etc/etcd/pki/kube-apiserver-client.key
  x509.certificate_managed:
    - public_key: /etc/etcd/pki/kube-apiserver-client.key
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