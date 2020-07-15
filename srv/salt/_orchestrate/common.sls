common_state:
  salt.state:
    - tgt: 'G@role:edge or G@role:etcd or G@role:master or G@role:node'
    - tgt_type: compound
    - sls: common
    - queue: True

docker_state:
  salt.state:
    - tgt: 'G@role:edge or G@role:etcd or G@role:master or G@role:node'
    - tgt_type: compound
    - sls: kubernetes.cri.docker
    - queue: True
    - require:
      - salt: common_state
