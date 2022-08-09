projectatomic-repo:
  pkgrepo.managed:
    - humanname: Project Atomic PPA
    - name: deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_22.04
    - dist: bionic
    - file: /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
    - key_url: https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_22.04/Release.key

flatpak-repo:
  pkgrepo.managed:
    - humanname: Flatpak PPA
    - name: deb http://ppa.launchpad.net/alexlarsson/flatpak/ubuntu jammy main
    - dist: jammy
    - file: /etc/apt/sources.list.d/flatpak.list
    - keyid: FA577F07
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - pkg: ostree