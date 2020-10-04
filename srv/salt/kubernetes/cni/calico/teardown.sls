calico-teardown:
  cmd.run:
    - runas: root
    - name: |
        kubectl delete -f /srv/kubernetes/manifests/calico/calico-typha.yaml

/srv/kubernetes/manifests/calico/calico-typha.yaml:
    file.absent:
    - require:
      - cmd: calico-teardown
    - source: salt://{{ tpldir }}/templates/calico-typha.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}