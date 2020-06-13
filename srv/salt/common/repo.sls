azure-cli:
  pkgrepo.managed:
    - name: deb https://packages.microsoft.com/repos/azure-cli/ bionic main
    - dist: bionic
    - file: /etc/apt/sources.list.d/azure-cli.list
    - gpgcheck: 1
    - key_url: https://packages.microsoft.com/keys/microsoft.asc