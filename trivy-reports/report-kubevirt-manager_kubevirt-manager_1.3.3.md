
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


kubevirtmanager/kubevirt-manager:1.3.3 (alpine 3.18.6)
======================================================
Total: 8 (HIGH: 6, CRITICAL: 2)

┌──────────┬────────────────┬──────────┬────────┬───────────────────┬───────────────┬─────────────────────────────────────────────────────────────┐
│ Library  │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version │                            Title                            │
├──────────┼────────────────┼──────────┼────────┼───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ curl     │ CVE-2024-2398  │ HIGH     │ fixed  │ 8.5.0-r0          │ 8.7.1-r0      │ curl: HTTP/2 push headers memory-leak                       │
│          │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-2398                   │
│          ├────────────────┤          │        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│          │ CVE-2024-6197  │          │        │                   │ 8.9.0-r0      │ curl: freeing stack buffer in utf8asn1str                   │
│          │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-6197                   │
├──────────┼────────────────┤          │        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│ libcurl  │ CVE-2024-2398  │          │        │                   │ 8.7.1-r0      │ curl: HTTP/2 push headers memory-leak                       │
│          │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-2398                   │
│          ├────────────────┤          │        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│          │ CVE-2024-6197  │          │        │                   │ 8.9.0-r0      │ curl: freeing stack buffer in utf8asn1str                   │
│          │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-6197                   │
├──────────┼────────────────┼──────────┤        ├───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ libexpat │ CVE-2024-45491 │ CRITICAL │        │ 2.6.0-r0          │ 2.6.3-r0      │ libexpat: Integer Overflow or Wraparound                    │
│          │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-45491                  │
│          ├────────────────┤          │        │                   │               ├─────────────────────────────────────────────────────────────┤
│          │ CVE-2024-45492 │          │        │                   │               │ libexpat: integer overflow                                  │
│          │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-45492                  │
│          ├────────────────┼──────────┤        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│          │ CVE-2024-28757 │ HIGH     │        │                   │ 2.6.2-r0      │ expat: XML Entity Expansion                                 │
│          │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-28757                  │
│          ├────────────────┤          │        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│          │ CVE-2024-45490 │          │        │                   │ 2.6.3-r0      │ libexpat: Negative Length Parsing Vulnerability in libexpat │
│          │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-45490                  │
└──────────┴────────────────┴──────────┴────────┴───────────────────┴───────────────┴─────────────────────────────────────────────────────────────┘

usr/local/bin/kubectl (gobinary)
================================
Total: 4 (HIGH: 3, CRITICAL: 1)

┌──────────────────┬────────────────┬──────────┬────────┬───────────────────┬─────────────────┬────────────────────────────────────────────────────────────┐
│     Library      │ Vulnerability  │ Severity │ Status │ Installed Version │  Fixed Version  │                           Title                            │
├──────────────────┼────────────────┼──────────┼────────┼───────────────────┼─────────────────┼────────────────────────────────────────────────────────────┤
│ golang.org/x/net │ CVE-2024-45338 │ HIGH     │ fixed  │ v0.19.0           │ 0.33.0          │ golang.org/x/net/html: Non-linear parsing of               │
│                  │                │          │        │                   │                 │ case-insensitive content in golang.org/x/net/html          │
│                  │                │          │        │                   │                 │ https://avd.aquasec.com/nvd/cve-2024-45338                 │
├──────────────────┼────────────────┼──────────┤        ├───────────────────┼─────────────────┼────────────────────────────────────────────────────────────┤
│ stdlib           │ CVE-2024-24790 │ CRITICAL │        │ v1.21.7           │ 1.21.11, 1.22.4 │ golang: net/netip: Unexpected behavior from Is methods for │
│                  │                │          │        │                   │                 │ IPv4-mapped IPv6 addresses                                 │
│                  │                │          │        │                   │                 │ https://avd.aquasec.com/nvd/cve-2024-24790                 │
│                  ├────────────────┼──────────┤        │                   ├─────────────────┼────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-45288 │ HIGH     │        │                   │ 1.21.9, 1.22.2  │ golang: net/http, x/net/http2: unlimited number of         │
│                  │                │          │        │                   │                 │ CONTINUATION frames causes DoS                             │
│                  │                │          │        │                   │                 │ https://avd.aquasec.com/nvd/cve-2023-45288                 │
│                  ├────────────────┤          │        │                   ├─────────────────┼────────────────────────────────────────────────────────────┤
│                  │ CVE-2024-34156 │          │        │                   │ 1.22.7, 1.23.1  │ encoding/gob: golang: Calling Decoder.Decode on a message  │
│                  │                │          │        │                   │                 │ which contains deeply nested structures...                 │
│                  │                │          │        │                   │                 │ https://avd.aquasec.com/nvd/cve-2024-34156                 │
└──────────────────┴────────────────┴──────────┴────────┴───────────────────┴─────────────────┴────────────────────────────────────────────────────────────┘
