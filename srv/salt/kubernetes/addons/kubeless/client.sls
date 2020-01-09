{%- from "kubernetes/map.jinja" import common with context -%}

kubeless-client:
  archive.extracted:
    - name: /tmp/kubeless-v{{ common.addons.kubeless.version }}
    - source: https://github.com/kubeless/kubeless/releases/download/v{{ common.addons.kubeless.version }}/kubeless_linux-amd64.zip
    - skip_verify: true
    {# - source_hash: {{ common.addons.kubeless.source_hash }} #}
    - user: root
    - group: root
    - archive_format: zip
    - enforce_toplevel: false
  file.copy:
    - name: /usr/local/bin/kubeless
    - source: /tmp/kubeless-v{{ common.addons.kubeless.version }}/bundles/kubeless_linux-amd64/kubeless
    - mode: 555
    - user: root
    - group: root
    - force: true
    - require:
      - archive: /tmp/kubeless-v{{ common.addons.kubeless.version }}
    - unless: cmp -s /usr/local/bin/kubeless /tmp/kubeless-v{{ common.addons.kubeless.version }}/bundles/kubeless_linux-amd64/kubeless