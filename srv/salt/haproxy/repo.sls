haproxy2-repo:
  pkgrepo.managed:
    - name: ppa:vbernat/haproxy-2.1
    - dist: jammy
    - file: /etc/apt/sources.list.d/logstash.list
    - keyid: CFFB779AADC995E4F350A060505D97A41C61B9CD 
    - keyserver: keyserver.ubuntu.com