envoy:
  salt.state:
    - tgt: 'role:edge'
    - tgt_type: grain
    - sls: envoy
    - queue: True
