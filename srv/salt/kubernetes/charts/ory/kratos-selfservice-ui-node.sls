kratos-selfservice-ui-node:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/ory/kratos-selfservice-ui-node-values.yaml
      - cmd: ory-namespace
      - cmd: kratos-selfservice-ui-node-fetch-charts
    - cwd: /srv/kubernetes/manifests/ory/kratos-selfservice-ui-node
    - name: |
        helm upgrade --install kratos-selfservice-ui-node --namespace ory \
          --values /srv/kubernetes/manifests/ory/kratos-selfservice-ui-node-values.yaml \
          "./" --wait --timeout 3m