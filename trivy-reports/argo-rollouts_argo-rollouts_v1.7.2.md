
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


quay.io/argoproj/argo-rollouts:v1.7.2 (debian 11.10)
====================================================
Total: 0 (HIGH: 0, CRITICAL: 0)


bin/rollouts-controller (gobinary)
==================================
Total: 7 (HIGH: 6, CRITICAL: 1)

┌──────────────────────────────────────────────────────────────┬─────────────────────┬──────────┬────────┬───────────────────┬──────────────────────────────────┬─────────────────────────────────────────────────────────────┐
│                           Library                            │    Vulnerability    │ Severity │ Status │ Installed Version │          Fixed Version           │                            Title                            │
├──────────────────────────────────────────────────────────────┼─────────────────────┼──────────┼────────┼───────────────────┼──────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ github.com/cloudflare/circl                                  │ GHSA-9763-4f94-gfch │ HIGH     │ fixed  │ v1.3.3            │ 1.3.7                            │ CIRCL's Kyber: timing side-channel (kyberslash2)            │
│                                                              │                     │          │        │                   │                                  │ https://github.com/advisories/GHSA-9763-4f94-gfch           │
├──────────────────────────────────────────────────────────────┼─────────────────────┤          │        ├───────────────────┼──────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ go.opentelemetry.io/contrib/instrumentation/google.golang.o- │ CVE-2023-47108      │          │        │ v0.42.0           │ 0.46.0                           │ opentelemetry-go-contrib: DoS vulnerability in otelgrpc due │
│ rg/grpc/otelgrpc                                             │                     │          │        │                   │                                  │ to unbound cardinality metrics                              │
│                                                              │                     │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-47108                  │
├──────────────────────────────────────────────────────────────┼─────────────────────┼──────────┤        ├───────────────────┼──────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ golang.org/x/crypto                                          │ CVE-2024-45337      │ CRITICAL │        │ v0.21.0           │ 0.31.0                           │ golang.org/x/crypto/ssh: Misuse of                          │
│                                                              │                     │          │        │                   │                                  │ ServerConfig.PublicKeyCallback may cause authorization      │
│                                                              │                     │          │        │                   │                                  │ bypass in golang.org/x/crypto                               │
│                                                              │                     │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-45337                  │
├──────────────────────────────────────────────────────────────┼─────────────────────┼──────────┤        ├───────────────────┼──────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ golang.org/x/net                                             │ CVE-2024-45338      │ HIGH     │        │ v0.22.0           │ 0.33.0                           │ golang.org/x/net/html: Non-linear parsing of                │
│                                                              │                     │          │        │                   │                                  │ case-insensitive content in golang.org/x/net/html           │
│                                                              │                     │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-45338                  │
├──────────────────────────────────────────────────────────────┼─────────────────────┤          │        ├───────────────────┼──────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ k8s.io/kubernetes                                            │ CVE-2024-10220      │          │        │ v1.29.3           │ 1.28.12, 1.29.7, 1.30.3          │ kubernetes: Arbitrary command execution through gitRepo     │
│                                                              │                     │          │        │                   │                                  │ volume                                                      │
│                                                              │                     │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-10220                  │
│                                                              ├─────────────────────┤          │        │                   ├──────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2024-5321       │          │        │                   │ 1.27.16, 1.28.12, 1.29.7, 1.30.3 │ kubelet: Incorrect permissions on Windows containers logs   │
│                                                              │                     │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-5321                   │
├──────────────────────────────────────────────────────────────┼─────────────────────┤          │        ├───────────────────┼──────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ stdlib                                                       │ CVE-2024-34156      │          │        │ v1.21.13          │ 1.22.7, 1.23.1                   │ encoding/gob: golang: Calling Decoder.Decode on a message   │
│                                                              │                     │          │        │                   │                                  │ which contains deeply nested structures...                  │
│                                                              │                     │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-34156                  │
└──────────────────────────────────────────────────────────────┴─────────────────────┴──────────┴────────┴───────────────────┴──────────────────────────────────┴─────────────────────────────────────────────────────────────┘
