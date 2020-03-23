common_packages:
  pkg.latest:
    - pkgs:
      - azure-cli
      - ceph-common
      - httpie
      - jq
      - python-m2crypto
      - python3-m2crypto
      - linux-image-{{ grains['kernelrelease'] }}
      - linux-headers-{{ grains['kernelrelease'] }}
    - refresh: true
    - reload_modules: true