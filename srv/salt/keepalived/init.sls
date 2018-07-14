# keepalived
#
# Meta-state to fully setup keepalived on debian. (or any other distro that has keepalived in their repo)

include:
  - keepalived.install
  - keepalived.service
  - keepalived.config