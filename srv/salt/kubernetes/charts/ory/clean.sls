hydra-teardown:
  cmd.run:
    - runas: root
    - name: |
        helm delete -n ory hydra
        {% if common.addons.get('rook_cockroachdb', {'enabled': False}).enabled and ory.hydra.get('cockroachdb', {'enabled': False}).enabled %}
        kubectl delete -f /srv/kubernetes/manifests/ory/hydra-cockroachdb.yaml

kratos-teardown:
  cmd.run:
    - runas: root
    - name: |
        helm delete -n ory kratos
        {% if common.addons.get('rook_cockroachdb', {'enabled': False}).enabled and ory.kratos.get('cockroachdb', {'enabled': False}).enabled %}
        kubectl delete -f /srv/kubernetes/manifests/ory/kratos-cockroachdb.yaml
