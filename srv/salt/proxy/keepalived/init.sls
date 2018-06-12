# keepalived
#
# Meta-state to fully setup keepalived on debian. (or any other distro that has keepalived in their repo)

include:
  - proxy.keepalived.install
  - proxy.keepalived.service
  - proxy.keepalived.config