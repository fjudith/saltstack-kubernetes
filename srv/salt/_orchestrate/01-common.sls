common:
  salt.state:
    - tgt: 'G@role:edge or G@role:etcd or G@role:master or G@role:node'
    - tgt_type: compound
    - sls: common
    - queue: True

helm:
  salt.state:
    - tgt: 'G@role:master'
    - tgt_type: compound
    - sls: kubernetes.helm
    - queue: True

loopback-iscsi:
  salt.state:
    - tgt: 'G@role:node'
    - tgt_type: compound
    - sls: loopback-iscsi
    - queue: True
    - require:
      - salt: common
