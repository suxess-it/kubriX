
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


grafana/tempo:2.5.0 (alpine 3.20.0)
===================================
Total: 0 (HIGH: 0, CRITICAL: 0)


tempo (gobinary)
================
Total: 9 (HIGH: 7, CRITICAL: 2)

┌─────────────────────────────────────────────────┬─────────────────────┬──────────┬────────┬───────────────────┬──────────────────────────────────┬────────────────────────────────────────────────────────────┐
│                     Library                     │    Vulnerability    │ Severity │ Status │ Installed Version │          Fixed Version           │                           Title                            │
├─────────────────────────────────────────────────┼─────────────────────┼──────────┼────────┼───────────────────┼──────────────────────────────────┼────────────────────────────────────────────────────────────┤
│ github.com/mostynb/go-grpc-compression          │ GHSA-87m9-rv8p-rgmg │ HIGH     │ fixed  │ v1.2.2            │ 1.2.3                            │ go-grpc-compression has a zstd decompression bombing       │
│                                                 │                     │          │        │                   │                                  │ vulnerability                                              │
│                                                 │                     │          │        │                   │                                  │ https://github.com/advisories/GHSA-87m9-rv8p-rgmg          │
├─────────────────────────────────────────────────┼─────────────────────┤          │        ├───────────────────┼──────────────────────────────────┼────────────────────────────────────────────────────────────┤
│ go.opentelemetry.io/collector/config/configgrpc │ CVE-2024-36129      │          │        │ v0.97.0           │ 0.102.1                          │ opentelemetry-collector: denial of service via specially   │
│                                                 │                     │          │        │                   │                                  │ crafted HTTP or gRPC request                               │
│                                                 │                     │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-36129                 │
├─────────────────────────────────────────────────┤                     │          │        │                   ├──────────────────────────────────┤                                                            │
│ go.opentelemetry.io/collector/config/confighttp │                     │          │        │                   │ 0.102.0                          │                                                            │
│                                                 │                     │          │        │                   │                                  │                                                            │
│                                                 │                     │          │        │                   │                                  │                                                            │
├─────────────────────────────────────────────────┼─────────────────────┼──────────┤        ├───────────────────┼──────────────────────────────────┼────────────────────────────────────────────────────────────┤
│ golang.org/x/crypto                             │ CVE-2024-45337      │ CRITICAL │        │ v0.22.0           │ 0.31.0                           │ golang.org/x/crypto/ssh: Misuse of                         │
│                                                 │                     │          │        │                   │                                  │ ServerConfig.PublicKeyCallback may cause authorization     │
│                                                 │                     │          │        │                   │                                  │ bypass in golang.org/x/crypto                              │
│                                                 │                     │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-45337                 │
├─────────────────────────────────────────────────┼─────────────────────┼──────────┤        ├───────────────────┼──────────────────────────────────┼────────────────────────────────────────────────────────────┤
│ golang.org/x/net                                │ CVE-2024-45338      │ HIGH     │        │ v0.24.0           │ 0.33.0                           │ golang.org/x/net/html: Non-linear parsing of               │
│                                                 │                     │          │        │                   │                                  │ case-insensitive content in golang.org/x/net/html          │
│                                                 │                     │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-45338                 │
├─────────────────────────────────────────────────┼─────────────────────┼──────────┤        ├───────────────────┼──────────────────────────────────┼────────────────────────────────────────────────────────────┤
│ stdlib                                          │ CVE-2024-24790      │ CRITICAL │        │ v1.21.3           │ 1.21.11, 1.22.4                  │ golang: net/netip: Unexpected behavior from Is methods for │
│                                                 │                     │          │        │                   │                                  │ IPv4-mapped IPv6 addresses                                 │
│                                                 │                     │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-24790                 │
│                                                 ├─────────────────────┼──────────┤        │                   ├──────────────────────────────────┼────────────────────────────────────────────────────────────┤
│                                                 │ CVE-2023-45283      │ HIGH     │        │                   │ 1.20.11, 1.21.4, 1.20.12, 1.21.5 │ The filepath package does not recognize paths with a \??\  │
│                                                 │                     │          │        │                   │                                  │ prefix as...                                               │
│                                                 │                     │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-45283                 │
│                                                 ├─────────────────────┤          │        │                   ├──────────────────────────────────┼────────────────────────────────────────────────────────────┤
│                                                 │ CVE-2023-45288      │          │        │                   │ 1.21.9, 1.22.2                   │ golang: net/http, x/net/http2: unlimited number of         │
│                                                 │                     │          │        │                   │                                  │ CONTINUATION frames causes DoS                             │
│                                                 │                     │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-45288                 │
│                                                 ├─────────────────────┤          │        │                   ├──────────────────────────────────┼────────────────────────────────────────────────────────────┤
│                                                 │ CVE-2024-34156      │          │        │                   │ 1.22.7, 1.23.1                   │ encoding/gob: golang: Calling Decoder.Decode on a message  │
│                                                 │                     │          │        │                   │                                  │ which contains deeply nested structures...                 │
│                                                 │                     │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-34156                 │
└─────────────────────────────────────────────────┴─────────────────────┴──────────┴────────┴───────────────────┴──────────────────────────────────┴────────────────────────────────────────────────────────────┘
