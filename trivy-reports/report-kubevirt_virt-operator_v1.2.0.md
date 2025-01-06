
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


quay.io/kubevirt/virt-operator:v1.2.0 (debian 12.4)
===================================================
Total: 4 (HIGH: 4, CRITICAL: 0)

┌─────────┬────────────────┬──────────┬────────┬───────────────────┬────────────────┬───────────────────────────────────────────────────────────┐
│ Library │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version  │                           Title                           │
├─────────┼────────────────┼──────────┼────────┼───────────────────┼────────────────┼───────────────────────────────────────────────────────────┤
│ libc6   │ CVE-2023-6246  │ HIGH     │ fixed  │ 2.36-9+deb12u3    │ 2.36-9+deb12u4 │ glibc: heap-based buffer overflow in __vsyslog_internal() │
│         │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2023-6246                 │
│         ├────────────────┤          │        │                   │                ├───────────────────────────────────────────────────────────┤
│         │ CVE-2023-6779  │          │        │                   │                │ glibc: off-by-one heap-based buffer overflow in           │
│         │                │          │        │                   │                │ __vsyslog_internal()                                      │
│         │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2023-6779                 │
│         ├────────────────┤          │        │                   ├────────────────┼───────────────────────────────────────────────────────────┤
│         │ CVE-2024-2961  │          │        │                   │ 2.36-9+deb12u6 │ glibc: Out of bounds write in iconv may lead to remote    │
│         │                │          │        │                   │                │ code...                                                   │
│         │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2024-2961                 │
│         ├────────────────┤          │        │                   ├────────────────┼───────────────────────────────────────────────────────────┤
│         │ CVE-2024-33599 │          │        │                   │ 2.36-9+deb12u7 │ glibc: stack-based buffer overflow in netgroup cache      │
│         │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2024-33599                │
└─────────┴────────────────┴──────────┴────────┴───────────────────┴────────────────┴───────────────────────────────────────────────────────────┘

usr/bin/csv-generator (gobinary)
================================
Total: 3 (HIGH: 2, CRITICAL: 1)

┌─────────┬────────────────┬──────────┬────────┬───────────────────┬─────────────────┬────────────────────────────────────────────────────────────┐
│ Library │ Vulnerability  │ Severity │ Status │ Installed Version │  Fixed Version  │                           Title                            │
├─────────┼────────────────┼──────────┼────────┼───────────────────┼─────────────────┼────────────────────────────────────────────────────────────┤
│ stdlib  │ CVE-2024-24790 │ CRITICAL │ fixed  │ v1.21.5           │ 1.21.11, 1.22.4 │ golang: net/netip: Unexpected behavior from Is methods for │
│         │                │          │        │                   │                 │ IPv4-mapped IPv6 addresses                                 │
│         │                │          │        │                   │                 │ https://avd.aquasec.com/nvd/cve-2024-24790                 │
│         ├────────────────┼──────────┤        │                   ├─────────────────┼────────────────────────────────────────────────────────────┤
│         │ CVE-2023-45288 │ HIGH     │        │                   │ 1.21.9, 1.22.2  │ golang: net/http, x/net/http2: unlimited number of         │
│         │                │          │        │                   │                 │ CONTINUATION frames causes DoS                             │
│         │                │          │        │                   │                 │ https://avd.aquasec.com/nvd/cve-2023-45288                 │
│         ├────────────────┤          │        │                   ├─────────────────┼────────────────────────────────────────────────────────────┤
│         │ CVE-2024-34156 │          │        │                   │ 1.22.7, 1.23.1  │ encoding/gob: golang: Calling Decoder.Decode on a message  │
│         │                │          │        │                   │                 │ which contains deeply nested structures...                 │
│         │                │          │        │                   │                 │ https://avd.aquasec.com/nvd/cve-2024-34156                 │
└─────────┴────────────────┴──────────┴────────┴───────────────────┴─────────────────┴────────────────────────────────────────────────────────────┘

usr/bin/virt-operator (gobinary)
================================
Total: 3 (HIGH: 2, CRITICAL: 1)

┌─────────┬────────────────┬──────────┬────────┬───────────────────┬─────────────────┬────────────────────────────────────────────────────────────┐
│ Library │ Vulnerability  │ Severity │ Status │ Installed Version │  Fixed Version  │                           Title                            │
├─────────┼────────────────┼──────────┼────────┼───────────────────┼─────────────────┼────────────────────────────────────────────────────────────┤
│ stdlib  │ CVE-2024-24790 │ CRITICAL │ fixed  │ v1.21.5           │ 1.21.11, 1.22.4 │ golang: net/netip: Unexpected behavior from Is methods for │
│         │                │          │        │                   │                 │ IPv4-mapped IPv6 addresses                                 │
│         │                │          │        │                   │                 │ https://avd.aquasec.com/nvd/cve-2024-24790                 │
│         ├────────────────┼──────────┤        │                   ├─────────────────┼────────────────────────────────────────────────────────────┤
│         │ CVE-2023-45288 │ HIGH     │        │                   │ 1.21.9, 1.22.2  │ golang: net/http, x/net/http2: unlimited number of         │
│         │                │          │        │                   │                 │ CONTINUATION frames causes DoS                             │
│         │                │          │        │                   │                 │ https://avd.aquasec.com/nvd/cve-2023-45288                 │
│         ├────────────────┤          │        │                   ├─────────────────┼────────────────────────────────────────────────────────────┤
│         │ CVE-2024-34156 │          │        │                   │ 1.22.7, 1.23.1  │ encoding/gob: golang: Calling Decoder.Decode on a message  │
│         │                │          │        │                   │                 │ which contains deeply nested structures...                 │
│         │                │          │        │                   │                 │ https://avd.aquasec.com/nvd/cve-2024-34156                 │
└─────────┴────────────────┴──────────┴────────┴───────────────────┴─────────────────┴────────────────────────────────────────────────────────────┘
