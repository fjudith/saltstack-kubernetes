{%- from "kubernetes/map.jinja" import common with context -%}
{%- set current_path = salt['environ.get']('PATH') -%}

projectatomic-repo:
  pkgrepo.managed:
    - humanname: Project Atomic PPA
    - name: deb http://ppa.launchpad.net/projectatomic/ppa/ubuntu/ xenial main
    - dist: xenial
    - file: /etc/apt/sources.list.d/projectatomic.list
    - keyid: 7AD8C79D
    - keyserver: keyserver.ubuntu.com

libdevmapper1.02.1:
  pkg.latest:
    - refresh: true

libgpgme11:
  pkg.latest:
    - refresh: true

libseccomp2:
  pkg.latest:
    - refresh: true

cri-o-runc:
  pkg.latest:
    - require:
      - pkgrepo: projectatomic-repo  
    - refresh: true
    - install_recommends: False

skopeo:
  pkg.latest:
    - require:
      - pkgrepo: projectatomic-repo  
    - refresh: true
    - install_recommends: False

skopeo-containers:
  pkg.latest:
    - require:
      - pkgrepo: projectatomic-repo  
    - refresh: true
    - install_recommends: False

cri-o-{{ common.cri.crio.version }}:
  pkg.latest:
    - require:
      - pkgrepo: projectatomic-repo
    - refresh: true
    - install_recommends: False

/etc/cni/net.d/100-crio-bridge.conf:
  file.absent:
    - watch:
      - pkg: cri-o-{{ common.cri.crio.version }}

/etc/cni/net.d/200-loopback.conf:
  file.absent:
    - watch:
      - pkg: cri-o-{{ common.cri.crio.version }}

ostree-install:
  pkgrepo.managed:
    - humanname: Flatpak PPA
    - name: deb http://ppa.launchpad.net/alexlarsson/flatpak/ubuntu bionic main
    - dist: bionic
    - file: /etc/apt/sources.list.d/flatpak.list
    - keyid: FA577F07
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - pkg: ostree
  pkg.latest:
    - name: ostree
    - refresh: true

/etc/containers:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/etc/containers/oci/hooks.d:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/etc/containers/policy.json:
  file.managed:
    - require:
      - file: /etc/containers
    - source: salt://kubernetes/cri/crio/policy.json
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/crio/seccomp.json:
  file.managed:
    - require:
      - file: /etc/containers
    - source: salt://kubernetes/cri/crio/seccomp.json
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/crio:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - makedirs: True

/lib/systemd/system/crio.service:
  file.managed:
    - require:
      - file: /etc/crio
    - source: salt://kubernetes/cri/crio/crio.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/lib/systemd/system/crio-shutdown.service:
  file.managed:
    - require:
      - file: /etc/crio
    - source: salt://kubernetes/cri/crio/crio-shutdown.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/crio/crio.conf:
  file.managed:
    - require:
      - file: /etc/crio
    - source: salt://kubernetes/cri/crio/crio.conf
    - user: root
    - template: jinja
    - group: root
    - mode: 644

crio.service:
  service.running:
    - watch:
      - pkg: cri-o-{{ common.cri.crio.version }}
      - file: /lib/systemd/system/crio.service
      - file: /etc/crio/crio.conf
      - file: /etc/crio/seccomp.json
      - file: /etc/containers/policy.json
      - file: /etc/cni/net.d/100-crio-bridge.conf
      - file: /etc/cni/net.d/200-loopback.conf
    - enable: True