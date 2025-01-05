
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


grafana/rollout-operator:v0.19.1 (debian 12.6)
==============================================
Total: 0 (HIGH: 0, CRITICAL: 0)


bin/rollout-operator (gobinary)
===============================
Total: 2 (HIGH: 2, CRITICAL: 0)

┌──────────────────┬────────────────┬──────────┬────────┬───────────────────┬────────────────┬───────────────────────────────────────────────────────────┐
│     Library      │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version  │                           Title                           │
├──────────────────┼────────────────┼──────────┼────────┼───────────────────┼────────────────┼───────────────────────────────────────────────────────────┤
│ golang.org/x/net │ CVE-2024-45338 │ HIGH     │ fixed  │ v0.26.0           │ 0.33.0         │ golang.org/x/net/html: Non-linear parsing of              │
│                  │                │          │        │                   │                │ case-insensitive content in golang.org/x/net/html         │
│                  │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2024-45338                │
├──────────────────┼────────────────┤          │        ├───────────────────┼────────────────┼───────────────────────────────────────────────────────────┤
│ stdlib           │ CVE-2024-34156 │          │        │ v1.23.0           │ 1.22.7, 1.23.1 │ encoding/gob: golang: Calling Decoder.Decode on a message │
│                  │                │          │        │                   │                │ which contains deeply nested structures...                │
│                  │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2024-34156                │
└──────────────────┴────────────────┴──────────┴────────┴───────────────────┴────────────────┴───────────────────────────────────────────────────────────┘
