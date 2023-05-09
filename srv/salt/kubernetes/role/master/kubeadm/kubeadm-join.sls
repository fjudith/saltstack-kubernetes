# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import kubeadm with context %}

kubeadm-join:
  file.managed:
    - name: /root/kubeadm-controlplane.yaml
    - source: salt://{{ tpldir }}/templates/kubeadm-controlplane.{{ kubeadm.apiVersion }}.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /root/kubeadm-controlplane.yaml
      - cmd: kubeadm-reset
    - require:
      - pkg: kubelet
      - pkg: kubectl
      - pkg: kubeadm
    - timeout: 600
    - name: |
        sleep {{ range(10, 30) | random }} && \
        /usr/bin/kubeadm join --config /root/kubeadm-controlplane.yaml --ignore-preflight-errors=all --v=5 \
        || /usr/bin/kubeadm reset -f --cert-dir /etc/kubernetes/pki
    - unless: test -f /etc/kubernetes/admin.conf

/root/.kube:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"

/root/.kube/config:
  file.symlink:
    - require:
      - file: /root/.kube
    - watch:
      - cmd: kubeadm-join
    - target: /etc/kubernetes/admin.conf
    - user: root
    - group: root
    - mode: "0444"
    - force: true