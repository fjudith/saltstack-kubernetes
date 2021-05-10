tekton-repo:
  pkgrepo.managed:
    - name: deb http://ppa.launchpad.net/tektoncd/cli/ubuntu focal main
    - dist: focal
    - file: /etc/apt/sources.list.d/tektoncd-ubuntu-cli.list
    - gpgcheck: 1
    - keyserver: keyserver.ubuntu.com
    - keyid: a40e52296e4cf9f90dd1e3bb3efe0e0a2f2f60aa