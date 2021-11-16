/var/log/kubernetes/audit:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: true

/etc/kubernetes/audit-policy:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: true

/etc/kubernetes/audit-policy/kube-apiserver-audit-policy.yaml:
  file.managed:
    - require:
      - file: /etc/kubernetes/audit-policy
    - user: root
    - group: root
    - dir_mode: "0644"
    - source: salt://{{ tpldir }}/files/kube-apiserver-audit-policy.yaml
    - context:
        tpldir: {{ tpldir }}