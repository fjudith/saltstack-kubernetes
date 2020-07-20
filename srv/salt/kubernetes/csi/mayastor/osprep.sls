/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages:
  file.line:
    - mode: insert
    - location: before
    - content: |
        1024

vm.nr_hugepages:
  sysctl.present:
    - value: 1024