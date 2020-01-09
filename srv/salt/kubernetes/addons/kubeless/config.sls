{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/kubeless:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/kubeless/kubeless-ui.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubeless
    - source: https://raw.githubusercontent.com/kubeless/kubeless-ui/{{ common.addons.kubeless.ui_version }}/k8s.yaml
    - skip_verify: true
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kubeless/kubeless.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubeless
    - source: https://github.com/kubeless/kubeless/releases/download/v{{ common.addons.kubeless.version }}/kubeless-v{{ common.addons.kubeless.version }}.yaml
    - skip_verify: true
    - user: root
    - group: root
    - mode: 644