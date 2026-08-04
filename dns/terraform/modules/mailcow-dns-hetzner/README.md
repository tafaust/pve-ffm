# Mailcow DNS records — Hetzner DNS

Prerequisite: zone exists; pass `zone_id` from `hetzner-dns-zone` module.

Covers common HTTP/mail discovery records (A, MX, SPF, optional DKIM/DMARC, autoconfig/autodiscover). **SRV** records for CalDAV/CardDAV and extra Mailcow services — add manually or extend module.

See [Mailcow DNS prerequisites](https://docs.mailcow.email/getstarted/prerequisite-dns/).
