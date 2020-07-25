hydra-secrets:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/ory
    - name: /srv/kubernetes/manifests/ory/hydra-secrets.yaml
    - source: salt://{{ tpldir }}/templates/hydra-secrets.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/ory/hydra-secrets.yaml
      - cmd: ory-namespace
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/ory/hydra-secrets.yaml

hydra:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/ory/hydra-values.yaml
      - cmd: ory-namespace
      - cmd: hydra-fetch-charts
    - cwd: /srv/kubernetes/manifests/ory/hydra
    - name: |
        helm upgrade --install hydra --namespace ory \
            --values /srv/kubernetes/manifests/ory/hydra-values.yaml \
            "./" --wait --timeout 3m