{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

vistio-addon:
  git.latest:
    - name: https://github.com/fjudith/vistio
    - target: /srv/kubernetes/manifests/vistio
    - force_reset: True
    - rev: v{{ charts.vistio.version }}

{% if common.addons.get('nginx', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/vistio-values.yaml:
    file.managed:
    - source: salt://kubernetes/charts/vistio/files/values-mesh-only.yaml
    - user: root
    - group: root
    - mode: 644
{%- else -%}
/srv/kubernetes/manifests/vistio-values.yaml:
    file.managed:
    - source: salt://kubernetes/charts/vistio/files/values-with-ingress.yaml
    - user: root
    - group: root
    - mode: 644
{% endif %}