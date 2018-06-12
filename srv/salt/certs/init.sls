/etc/kubernetes:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

{# /srv/kubernetes/ca.pem:
  file.managed:
    - source:  salt://certs/ca.pem
    - group: root
    - mode: 644

/srv/kubernetes/ca-key.pem:
  file.managed:
    - source:  salt://certs/ca-key.pem
    - group: root
    - mode: 600

/srv/kubernetes/kubernetes-key.pem:
  file.managed:
    - source:  salt://certs/kubernetes-key.pem
    - group: root
    - mode: 600

/srv/kubernetes/kubernetes.pem:
  file.managed:
    - source:  salt://certs/kubernetes.pem
    - group: root
    - mode: 644 #}

## Token & Auth Policy
/etc/kubernetes/token.csv:
  file.managed:
    - source:  salt://certs/token.csv
    - template: jinja
    - group: root
    - mode: 600
