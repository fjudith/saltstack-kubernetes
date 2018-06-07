

{%- set cluster_domain = pillar['kubernetes']['domain'] -%}
{%- set vpn_subnet = pillar['kubernetes']['global']['vpnIP-range'] -%}
{%- set proxy_server = pillar['kubernetes']['global']['proxy']['ipaddr'] -%}
{%- set proxy_port = pillar['kubernetes']['global']['proxy']['port'] -%}


proxy_server:
   environ.setenv:
     - name: tinyproxy
     - update_minion: True
     - value:
         http_proxy: http://{{ proxy_server }}:{{ proxy_port }}
         https_proxy: http://{{ proxy_server }}:{{ proxy_port }}
         no_proxy: "localhost, 127.0.0.1, *.{{ cluster_domain }} {{ vpn_subnet }}"