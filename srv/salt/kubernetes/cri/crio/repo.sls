projectatomic-repo:
  pkgrepo.managed:
    - humanname: Project Atomic PPA
    - name: deb http://ppa.launchpad.net/projectatomic/ppa/ubuntu/ xenial main
    - dist: xenial
    - file: /etc/apt/sources.list.d/projectatomic.list
    - keyid: 7AD8C79D
    - keyserver: keyserver.ubuntu.com

flatpak-repo:
  pkgrepo.managed:
    - humanname: Flatpak PPA
    - name: deb http://ppa.launchpad.net/alexlarsson/flatpak/ubuntu bionic main
    - dist: bionic
    - file: /etc/apt/sources.list.d/flatpak.list
    - keyid: FA577F07
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - pkg: ostree