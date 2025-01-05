
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


docker.io/dserio83/velero-ui:0.1.17 (alpine 3.19.0)
===================================================
Total: 0 (HIGH: 0, CRITICAL: 0)


Node.js (node-pkg)
==================
Total: 3 (HIGH: 3, CRITICAL: 0)

┌────────────────────────────┬────────────────┬──────────┬────────┬───────────────────┬─────────────────┬───────────────────────────────────────────────────┐
│          Library           │ Vulnerability  │ Severity │ Status │ Installed Version │  Fixed Version  │                       Title                       │
├────────────────────────────┼────────────────┼──────────┼────────┼───────────────────┼─────────────────┼───────────────────────────────────────────────────┤
│ cross-spawn (package.json) │ CVE-2024-21538 │ HIGH     │ fixed  │ 7.0.3             │ 7.0.5, 6.0.6    │ cross-spawn: regular expression denial of service │
│                            │                │          │        │                   │                 │ https://avd.aquasec.com/nvd/cve-2024-21538        │
├────────────────────────────┼────────────────┤          │        ├───────────────────┼─────────────────┼───────────────────────────────────────────────────┤
│ next (package.json)        │ CVE-2024-46982 │          │        │ 14.1.2            │ 13.5.7, 14.2.10 │ Next.js Cache Poisoning                           │
│                            │                │          │        │                   │                 │ https://avd.aquasec.com/nvd/cve-2024-46982        │
│                            ├────────────────┤          │        │                   ├─────────────────┼───────────────────────────────────────────────────┤
│                            │ CVE-2024-51479 │          │        │                   │ 14.2.15         │ next.js: next: authorization bypass in Next.js    │
│                            │                │          │        │                   │                 │ https://avd.aquasec.com/nvd/cve-2024-51479        │
└────────────────────────────┴────────────────┴──────────┴────────┴───────────────────┴─────────────────┴───────────────────────────────────────────────────┘

app/node_modules/@esbuild/linux-x64/bin/esbuild (gobinary)
==========================================================
Total: 5 (HIGH: 4, CRITICAL: 1)

┌─────────┬────────────────┬──────────┬────────┬───────────────────┬──────────────────────────────────┬──────────────────────────────────────────────────────────────┐
│ Library │ Vulnerability  │ Severity │ Status │ Installed Version │          Fixed Version           │                            Title                             │
├─────────┼────────────────┼──────────┼────────┼───────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ stdlib  │ CVE-2024-24790 │ CRITICAL │ fixed  │ v1.20.7           │ 1.21.11, 1.22.4                  │ golang: net/netip: Unexpected behavior from Is methods for   │
│         │                │          │        │                   │                                  │ IPv4-mapped IPv6 addresses                                   │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-24790                   │
│         ├────────────────┼──────────┤        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2023-39325 │ HIGH     │        │                   │ 1.20.10, 1.21.3                  │ golang: net/http, x/net/http2: rapid stream resets can cause │
│         │                │          │        │                   │                                  │ excessive work (CVE-2023-44487)                              │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2023-45283 │          │        │                   │ 1.20.11, 1.21.4, 1.20.12, 1.21.5 │ The filepath package does not recognize paths with a \??\    │
│         │                │          │        │                   │                                  │ prefix as...                                                 │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-45283                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2023-45288 │          │        │                   │ 1.21.9, 1.22.2                   │ golang: net/http, x/net/http2: unlimited number of           │
│         │                │          │        │                   │                                  │ CONTINUATION frames causes DoS                               │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-45288                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2024-34156 │          │        │                   │ 1.22.7, 1.23.1                   │ encoding/gob: golang: Calling Decoder.Decode on a message    │
│         │                │          │        │                   │                                  │ which contains deeply nested structures...                   │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-34156                   │
└─────────┴────────────────┴──────────┴────────┴───────────────────┴──────────────────────────────────┴──────────────────────────────────────────────────────────────┘
