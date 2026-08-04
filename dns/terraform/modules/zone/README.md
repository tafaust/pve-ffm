# Zone modules (legacy pointer)

Use **`hetzner-dns-zone`** or **`ionos-dns-zone`** from `terraform/modules/`. Hostinger has no zone resource — create zone in hPanel, then use **`mailcow-dns-hostinger`** or extend with raw `hostinger_dns_record` resources.

The old `dns_provider` switch in a single root was removed to avoid configuring three providers at once.
