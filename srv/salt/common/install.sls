common_packages:
  pkg.latest:
    - pkgs:
      - azure-cli
      - ceph-common
      - httpie
      - jq
      - python-m2crypto
      - python3-m2crypto
    - refresh: true
    - reload_modules: true