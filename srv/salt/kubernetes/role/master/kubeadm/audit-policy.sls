/etc/kubernetes/audit-policy:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: true

/var/log/kubernetes/audit:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: true

/etc/kubernetes/audit-policy/kube-apiserver-audit-policy.yaml:
  file.managed:
    - require:
      - file: /etc/kubernetes/audit-policy
    - user: root
    - group: root
    - dir_mode: 644
    - source: salt://kubernetes/role/master/kubeadm/templates/kube-apiserver-audit-policy.yaml.j2
    - template: jinja