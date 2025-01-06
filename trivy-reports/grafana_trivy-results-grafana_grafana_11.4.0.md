
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


docker.io/grafana/grafana:11.4.0 (alpine 3.20.3)
================================================
Total: 0 (HIGH: 0, CRITICAL: 0)


usr/share/grafana/bin/grafana (gobinary)
========================================
Total: 2 (HIGH: 1, CRITICAL: 1)

┌─────────────────────┬────────────────┬──────────┬────────┬───────────────────┬───────────────┬────────────────────────────────────────────────────────┐
│       Library       │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version │                         Title                          │
├─────────────────────┼────────────────┼──────────┼────────┼───────────────────┼───────────────┼────────────────────────────────────────────────────────┤
│ golang.org/x/crypto │ CVE-2024-45337 │ CRITICAL │ fixed  │ v0.27.0           │ 0.31.0        │ golang.org/x/crypto/ssh: Misuse of                     │
│                     │                │          │        │                   │               │ ServerConfig.PublicKeyCallback may cause authorization │
│                     │                │          │        │                   │               │ bypass in golang.org/x/crypto                          │
│                     │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-45337             │
├─────────────────────┼────────────────┼──────────┤        ├───────────────────┼───────────────┼────────────────────────────────────────────────────────┤
│ golang.org/x/net    │ CVE-2024-45338 │ HIGH     │        │ v0.29.0           │ 0.33.0        │ golang.org/x/net/html: Non-linear parsing of           │
│                     │                │          │        │                   │               │ case-insensitive content in golang.org/x/net/html      │
│                     │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-45338             │
└─────────────────────┴────────────────┴──────────┴────────┴───────────────────┴───────────────┴────────────────────────────────────────────────────────┘
