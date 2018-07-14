# keepalived
#
# Meta-state to fully setup keepalived on debian. (or any other distro that has keepalived in their repo)

include:
  - kubernetes.proxy.keepalived.install
  - kubernetes.proxy.keepalived.service
  - kubernetes.proxy.keepalived.config