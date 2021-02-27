/srv/kubernetes/manifests/opa/certs/ca.key:
  x509.private_key_managed:
    - bits: 4096
    - new: True
    - cipher: des_ede3_cbc
    {% if salt['file.file_exists']('/srv/kubernetes/manifests/opa/certs/ca.key') -%}
    - prereq:
      - x509: /srv/kubernetes/manifests/opa/certs/ca.crt
    {%- endif %}

/srv/kubernetes/manifests/opa/certs/ca.crt:
  x509.certificate_managed:
    - signing_private_key: /srv/kubernetes/manifests/opa/certs/ca.key
    - CN: "Open Policy Agent Root CA"
    - O: kubernetes
    - OU: OPA
    - basicConstraints: "critical CA:true"
    - keyUsage: "critical cRLSign, keyCertSign"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: 3650
    - days_remaining: 30
    - backup: True
    - require:
      - file: /srv/kubernetes/manifests/opa/certs

/srv/kubernetes/manifests/opa/certs/server.key:
  x509.private_key_managed:
    - bits: 4096
    - new: True
    - cipher: des_ede3_cbc
    {% if salt['file.file_exists']('/srv/kubernetes/manifests/opa/certs/server.key') -%}
    - prereq:
      - x509: /srv/kubernetes/manifests/opa/certs/server.crt
    {%- endif %}

/srv/kubernetes/manifests/opa/certs/server.crt:
  x509.certificate_managed:
    - signing_private_key: /srv/kubernetes/manifests/opa/certs/ca.key
    - signing_cert: /srv/kubernetes/manifests/opa/certs/ca.crt
    - CN: opa.opa.svc
    - O: kubernetes
    - OU: OPA
    - basicConstraints: "critical CA:false"
    - keyUsage: "critical, nonRepudiation, digitalSignature, keyEncipherment, keyAgreement"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: 3649
    - days_remaining: 30
    - backup: True
    - require:
      - file: /srv/kubernetes/manifests/opa/certs