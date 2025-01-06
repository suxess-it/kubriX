
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


quay.io/minio/mc:RELEASE.2024-04-18T16-45-29Z (redhat 9.3)
==========================================================
Total: 6 (HIGH: 6, CRITICAL: 0)

┌────────────────────────┬────────────────┬──────────┬────────┬───────────────────┬──────────────────┬────────────────────────────────────────────────────────┐
│        Library         │ Vulnerability  │ Severity │ Status │ Installed Version │  Fixed Version   │                         Title                          │
├────────────────────────┼────────────────┼──────────┼────────┼───────────────────┼──────────────────┼────────────────────────────────────────────────────────┤
│ glibc                  │ CVE-2024-2961  │ HIGH     │ fixed  │ 2.34-83.el9_3.12  │ 2.34-100.el9_4.2 │ glibc: Out of bounds write in iconv may lead to remote │
│                        │                │          │        │                   │                  │ code...                                                │
│                        │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-2961              │
│                        ├────────────────┤          │        │                   │                  ├────────────────────────────────────────────────────────┤
│                        │ CVE-2024-33599 │          │        │                   │                  │ glibc: stack-based buffer overflow in netgroup cache   │
│                        │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-33599             │
├────────────────────────┼────────────────┤          │        │                   │                  ├────────────────────────────────────────────────────────┤
│ glibc-common           │ CVE-2024-2961  │          │        │                   │                  │ glibc: Out of bounds write in iconv may lead to remote │
│                        │                │          │        │                   │                  │ code...                                                │
│                        │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-2961              │
│                        ├────────────────┤          │        │                   │                  ├────────────────────────────────────────────────────────┤
│                        │ CVE-2024-33599 │          │        │                   │                  │ glibc: stack-based buffer overflow in netgroup cache   │
│                        │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-33599             │
├────────────────────────┼────────────────┤          │        │                   │                  ├────────────────────────────────────────────────────────┤
│ glibc-minimal-langpack │ CVE-2024-2961  │          │        │                   │                  │ glibc: Out of bounds write in iconv may lead to remote │
│                        │                │          │        │                   │                  │ code...                                                │
│                        │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-2961              │
│                        ├────────────────┤          │        │                   │                  ├────────────────────────────────────────────────────────┤
│                        │ CVE-2024-33599 │          │        │                   │                  │ glibc: stack-based buffer overflow in netgroup cache   │
│                        │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-33599             │
└────────────────────────┴────────────────┴──────────┴────────┴───────────────────┴──────────────────┴────────────────────────────────────────────────────────┘

usr/bin/mc (gobinary)
=====================
Total: 4 (HIGH: 2, CRITICAL: 2)

┌─────────────────────┬────────────────┬──────────┬────────┬───────────────────┬─────────────────┬────────────────────────────────────────────────────────────┐
│       Library       │ Vulnerability  │ Severity │ Status │ Installed Version │  Fixed Version  │                           Title                            │
├─────────────────────┼────────────────┼──────────┼────────┼───────────────────┼─────────────────┼────────────────────────────────────────────────────────────┤
│ golang.org/x/crypto │ CVE-2024-45337 │ CRITICAL │ fixed  │ v0.22.0           │ 0.31.0          │ golang.org/x/crypto/ssh: Misuse of                         │
│                     │                │          │        │                   │                 │ ServerConfig.PublicKeyCallback may cause authorization     │
│                     │                │          │        │                   │                 │ bypass in golang.org/x/crypto                              │
│                     │                │          │        │                   │                 │ https://avd.aquasec.com/nvd/cve-2024-45337                 │
├─────────────────────┼────────────────┼──────────┤        ├───────────────────┼─────────────────┼────────────────────────────────────────────────────────────┤
│ golang.org/x/net    │ CVE-2024-45338 │ HIGH     │        │ v0.24.0           │ 0.33.0          │ golang.org/x/net/html: Non-linear parsing of               │
│                     │                │          │        │                   │                 │ case-insensitive content in golang.org/x/net/html          │
│                     │                │          │        │                   │                 │ https://avd.aquasec.com/nvd/cve-2024-45338                 │
├─────────────────────┼────────────────┼──────────┤        ├───────────────────┼─────────────────┼────────────────────────────────────────────────────────────┤
│ stdlib              │ CVE-2024-24790 │ CRITICAL │        │ v1.21.9           │ 1.21.11, 1.22.4 │ golang: net/netip: Unexpected behavior from Is methods for │
│                     │                │          │        │                   │                 │ IPv4-mapped IPv6 addresses                                 │
│                     │                │          │        │                   │                 │ https://avd.aquasec.com/nvd/cve-2024-24790                 │
│                     ├────────────────┼──────────┤        │                   ├─────────────────┼────────────────────────────────────────────────────────────┤
│                     │ CVE-2024-34156 │ HIGH     │        │                   │ 1.22.7, 1.23.1  │ encoding/gob: golang: Calling Decoder.Decode on a message  │
│                     │                │          │        │                   │                 │ which contains deeply nested structures...                 │
│                     │                │          │        │                   │                 │ https://avd.aquasec.com/nvd/cve-2024-34156                 │
└─────────────────────┴────────────────┴──────────┴────────┴───────────────────┴─────────────────┴────────────────────────────────────────────────────────────┘
