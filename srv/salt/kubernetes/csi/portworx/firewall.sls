# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import portworx with context %}
{%- set os = salt['grains.get']('os') -%}

{% if os == "Ubuntu" %}
portworx-open-ports:
  cmd.run:
    - runas: root
    - name: |
        /usr/sbin/ufw allow in on {{ portworx.dataplane_interface }} to any port 9001:9022 proto tcp
        /usr/sbin/ufw allow in on {{ portworx.dataplane_interface }} to any port 9002 proto udp
        /usr/sbin/ufw allow in on {{ portworx.dataplane_interface }} to any port 3260 proto tcp
        /usr/sbin/ufw allow in on {{ portworx.dataplane_interface }} to any port 3260 proto udp
        /usr/sbin/ufw allow in on {{ portworx.dataplane_interface }} to any port 111,2049,20048,20049 proto tcp
        /usr/sbin/ufw allow in on {{ portworx.dataplane_interface }} to any port 111,2049,20048,20049 proto udp
{% elif os == "Debian" %}
portworx-tcp:
  iptables.append:
    - comment: "Allow Portworx TCP"
    - in-interface: {{ portworx.dataplane_interface }}
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 9001:9022
    - protocol: tcp
    - sport: 1025:65535
    - save: True

portworx-udp:
  iptables.append:
    - comment: "Allow Portworx TCP"
    - in-interface: {{ portworx.dataplane_interface }}
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 9002
    - protocol: udp
    - sport: 1025:65535
    - save: True

iscsi-tcp:
  iptables.append:
    - comment: "Allow ISCSI TCP"
    - in-interface: {{ portworx.dataplane_interface }}
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 3260
    - protocol: udp
    - sport: 1025:65535
    - save: True
  
iscsi-udp:
  iptables.append:
    - comment: "Allow ISCSI UDP"
    - in-interface: {{ portworx.dataplane_interface }}
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 3260
    - protocol: udp
    - sport: 1025:65535
    - save: True

nfs-tcp:
  iptables.append:
    - comment: "Allow NFS TCP"
    - in-interface: {{ portworx.dataplane_interface }}
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 111,2049,20048,20049
    - protocol: tcp
    - sport: 1025:65535
    - save: True

nfs-udp:
  iptables.append:
    - comment: "Allow NFS UDP"
    - in-interface: {{ portworx.dataplane_interface }}
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 111,2049,20048,20049
    - protocol: udp
    - sport: 1025:65535
    - save: True
{% endif %}