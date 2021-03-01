{% set cri_provider = salt['pillar.get']('kubernetes:common:cri:provider') %}

common_state:
  salt.state:
    - tgt: 'G@role:edge or G@role:etcd or G@role:master or G@role:node'
    - tgt_type: compound
    - sls: common
    - queue: True

{{ cri_provider }}_state:
  salt.state:
    - tgt: 'G@role:edge or G@role:etcd or G@role:master or G@role:node'
    - tgt_type: compound
    - sls: kubernetes.cri.{{ cri_provider }}
    - queue: True
    - require:
      - salt: common_state
