# CoreDNS

[CoreDNS](https://coredns.io) is a DNS server writtend in [Go](https://golang.org/) that manage the Kubernetes service name resolution.

## Customization

The CoreDNS configuration has been customized to loadbalance forwarded requests between:

* The instance provider: `/etc/resolv.conf`
* The Google DNS service: `8.8.8.8 8.8.4.4`
* The Cloudflare DNS service: `1.1.1.1 1.0.0.1`

## Reference

* <https://github.com/coredns/coredns/issues/1986>
