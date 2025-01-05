
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


velero/velero:v1.14.1 (ubuntu 22.04)
====================================
Total: 0 (HIGH: 0, CRITICAL: 0)


usr/bin/restic (gobinary)
=========================
Total: 3 (HIGH: 2, CRITICAL: 1)

┌─────────────────────┬────────────────┬──────────┬────────┬───────────────────┬────────────────┬───────────────────────────────────────────────────────────┐
│       Library       │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version  │                           Title                           │
├─────────────────────┼────────────────┼──────────┼────────┼───────────────────┼────────────────┼───────────────────────────────────────────────────────────┤
│ golang.org/x/crypto │ CVE-2024-45337 │ CRITICAL │ fixed  │ v0.21.0           │ 0.31.0         │ golang.org/x/crypto/ssh: Misuse of                        │
│                     │                │          │        │                   │                │ ServerConfig.PublicKeyCallback may cause authorization    │
│                     │                │          │        │                   │                │ bypass in golang.org/x/crypto                             │
│                     │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2024-45337                │
├─────────────────────┼────────────────┼──────────┤        ├───────────────────┼────────────────┼───────────────────────────────────────────────────────────┤
│ golang.org/x/net    │ CVE-2024-45338 │ HIGH     │        │ v0.23.0           │ 0.33.0         │ golang.org/x/net/html: Non-linear parsing of              │
│                     │                │          │        │                   │                │ case-insensitive content in golang.org/x/net/html         │
│                     │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2024-45338                │
├─────────────────────┼────────────────┤          │        ├───────────────────┼────────────────┼───────────────────────────────────────────────────────────┤
│ stdlib              │ CVE-2024-34156 │          │        │ v1.22.6           │ 1.22.7, 1.23.1 │ encoding/gob: golang: Calling Decoder.Decode on a message │
│                     │                │          │        │                   │                │ which contains deeply nested structures...                │
│                     │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2024-34156                │
└─────────────────────┴────────────────┴──────────┴────────┴───────────────────┴────────────────┴───────────────────────────────────────────────────────────┘

velero (gobinary)
=================
Total: 3 (HIGH: 2, CRITICAL: 1)

┌─────────────────────┬────────────────┬──────────┬────────┬───────────────────┬────────────────┬───────────────────────────────────────────────────────────┐
│       Library       │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version  │                           Title                           │
├─────────────────────┼────────────────┼──────────┼────────┼───────────────────┼────────────────┼───────────────────────────────────────────────────────────┤
│ golang.org/x/crypto │ CVE-2024-45337 │ CRITICAL │ fixed  │ v0.24.0           │ 0.31.0         │ golang.org/x/crypto/ssh: Misuse of                        │
│                     │                │          │        │                   │                │ ServerConfig.PublicKeyCallback may cause authorization    │
│                     │                │          │        │                   │                │ bypass in golang.org/x/crypto                             │
│                     │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2024-45337                │
├─────────────────────┼────────────────┼──────────┤        ├───────────────────┼────────────────┼───────────────────────────────────────────────────────────┤
│ golang.org/x/net    │ CVE-2024-45338 │ HIGH     │        │ v0.26.0           │ 0.33.0         │ golang.org/x/net/html: Non-linear parsing of              │
│                     │                │          │        │                   │                │ case-insensitive content in golang.org/x/net/html         │
│                     │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2024-45338                │
├─────────────────────┼────────────────┤          │        ├───────────────────┼────────────────┼───────────────────────────────────────────────────────────┤
│ stdlib              │ CVE-2024-34156 │          │        │ v1.22.6           │ 1.22.7, 1.23.1 │ encoding/gob: golang: Calling Decoder.Decode on a message │
│                     │                │          │        │                   │                │ which contains deeply nested structures...                │
│                     │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2024-34156                │
└─────────────────────┴────────────────┴──────────┴────────┴───────────────────┴────────────────┴───────────────────────────────────────────────────────────┘

velero-helper (gobinary)
========================
Total: 1 (HIGH: 1, CRITICAL: 0)

┌─────────┬────────────────┬──────────┬────────┬───────────────────┬────────────────┬───────────────────────────────────────────────────────────┐
│ Library │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version  │                           Title                           │
├─────────┼────────────────┼──────────┼────────┼───────────────────┼────────────────┼───────────────────────────────────────────────────────────┤
│ stdlib  │ CVE-2024-34156 │ HIGH     │ fixed  │ v1.22.6           │ 1.22.7, 1.23.1 │ encoding/gob: golang: Calling Decoder.Decode on a message │
│         │                │          │        │                   │                │ which contains deeply nested structures...                │
│         │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2024-34156                │
└─────────┴────────────────┴──────────┴────────┴───────────────────┴────────────────┴───────────────────────────────────────────────────────────┘
