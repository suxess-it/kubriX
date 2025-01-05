
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


gcr.io/kubecost1/kubecost-modeling:v0.1.16 (wolfi 20230201)
===========================================================
Total: 2 (HIGH: 2, CRITICAL: 0)

┌──────────────────┬────────────────┬──────────┬────────┬───────────────────┬───────────────┬────────────────────────────────────────────┐
│     Library      │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version │                   Title                    │
├──────────────────┼────────────────┼──────────┼────────┼───────────────────┼───────────────┼────────────────────────────────────────────┤
│ python-3.12      │ CVE-2024-12254 │ HIGH     │ fixed  │ 3.12.5-r3         │ 3.12.8-r1     │ python: Unbounded memory buffering in      │
│                  │                │          │        │                   │               │ SelectorSocketTransport.writelines()       │
│                  │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-12254 │
├──────────────────┤                │          │        │                   │               │                                            │
│ python-3.12-base │                │          │        │                   │               │                                            │
│                  │                │          │        │                   │               │                                            │
│                  │                │          │        │                   │               │                                            │
└──────────────────┴────────────────┴──────────┴────────┴───────────────────┴───────────────┴────────────────────────────────────────────┘
