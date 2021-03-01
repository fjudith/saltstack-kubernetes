{#- Get the `tplroot` from `tpldir` #}
{%- from tpldir ~ "/map.jinja" import containerd with context %}

{% set repo_state = 'absent' %}
{% if containerd.use_upstream_repo or containerd.use_old_repo %}
  {% set repo_state = 'managed' %}
{% endif %}

{% set humanname_old = 'Old ' if containerd.use_old_repo else '' %}

{%- if grains['os_family']|lower in ('debian',) %}
{% set url = 'https://download.docker.com/linux/ubuntu ' ~ grains["oscodename"] ~ ' stable' %}

docker-package-repository:
  pkgrepo.{{ repo_state }}:
    - humanname: {{ grains["os"] }} {{ grains["oscodename"]|capitalize }} {{ humanname_old }}Docker Package Repository
    - name: deb [arch={{ grains["osarch"] }}] {{ url }}
    - file: /etc/apt/sources.list.d/docker.list
    - key_url: https://download.docker.com/linux/ubuntu/gpg
        {%- if grains['saltversioninfo'] >= [2018, 3, 0] %}
    - refresh: True
        {%- else %}
    - refresh_db: True
        {%- endif %}
    {# - require_in:
      - pkg: docker
    - require:
      - pkg: docker-dependencies #}

{%- elif grains['os_family']|lower in ('redhat',) %}
{% set url = 'https://yum.dockerproject.org/repo/main/centos/$releasever/' if containerd.use_old_repo else containerd.repo.url_base %}

docker-package-repository:
  pkgrepo.{{ repo_state }}:
    - name: docker-ce-stable
    - humanname: {{ grains['os'] }} {{ grains["oscodename"]|capitalize }} {{ humanname_old }}Docker Package Repository
    - baseurl: {{ url }}
    - enabled: 1
    - gpgcheck: 1
    {% if docker.use_old_repo %}
    - gpgkey: https://yum.dockerproject.org/gpg
    {% else %}
    - gpgkey: https://download.docker.com/linux/centos/gpg
    {% endif %}
    {# - require_in:
      - pkg: docker-package
    - require:
      - pkg: docker-package-dependencies #}

{%- else %}
docker-package-repository: {}
{%- endif %}