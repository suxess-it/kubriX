
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


bitnami/kubectl:1.30.2 (debian 12.6)
====================================
Total: 13 (HIGH: 9, CRITICAL: 4)

┌───────────┬────────────────┬──────────┬────────┬───────────────────┬────────────────────┬─────────────────────────────────────────────────────────────┐
│  Library  │ Vulnerability  │ Severity │ Status │ Installed Version │   Fixed Version    │                            Title                            │
├───────────┼────────────────┼──────────┼────────┼───────────────────┼────────────────────┼─────────────────────────────────────────────────────────────┤
│ git       │ CVE-2024-32002 │ CRITICAL │ fixed  │ 1:2.39.2-1.1      │ 1:2.39.5-0+deb12u1 │ git: Recursive clones RCE                                   │
│           │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-32002                  │
│           ├────────────────┼──────────┤        │                   │                    ├─────────────────────────────────────────────────────────────┤
│           │ CVE-2023-25652 │ HIGH     │        │                   │                    │ git: by feeding specially crafted input to `git apply       │
│           │                │          │        │                   │                    │ --reject`, a path...                                        │
│           │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-25652                  │
│           ├────────────────┤          │        │                   │                    ├─────────────────────────────────────────────────────────────┤
│           │ CVE-2023-29007 │          │        │                   │                    │ git: arbitrary configuration injection when renaming or     │
│           │                │          │        │                   │                    │ deleting a section from a...                                │
│           │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-29007                  │
│           ├────────────────┤          │        │                   │                    ├─────────────────────────────────────────────────────────────┤
│           │ CVE-2024-32004 │          │        │                   │                    │ git: RCE while cloning local repos                          │
│           │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-32004                  │
│           ├────────────────┤          │        │                   │                    ├─────────────────────────────────────────────────────────────┤
│           │ CVE-2024-32465 │          │        │                   │                    │ git: additional local RCE                                   │
│           │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-32465                  │
├───────────┼────────────────┼──────────┤        │                   │                    ├─────────────────────────────────────────────────────────────┤
│ git-man   │ CVE-2024-32002 │ CRITICAL │        │                   │                    │ git: Recursive clones RCE                                   │
│           │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-32002                  │
│           ├────────────────┼──────────┤        │                   │                    ├─────────────────────────────────────────────────────────────┤
│           │ CVE-2023-25652 │ HIGH     │        │                   │                    │ git: by feeding specially crafted input to `git apply       │
│           │                │          │        │                   │                    │ --reject`, a path...                                        │
│           │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-25652                  │
│           ├────────────────┤          │        │                   │                    ├─────────────────────────────────────────────────────────────┤
│           │ CVE-2023-29007 │          │        │                   │                    │ git: arbitrary configuration injection when renaming or     │
│           │                │          │        │                   │                    │ deleting a section from a...                                │
│           │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-29007                  │
│           ├────────────────┤          │        │                   │                    ├─────────────────────────────────────────────────────────────┤
│           │ CVE-2024-32004 │          │        │                   │                    │ git: RCE while cloning local repos                          │
│           │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-32004                  │
│           ├────────────────┤          │        │                   │                    ├─────────────────────────────────────────────────────────────┤
│           │ CVE-2024-32465 │          │        │                   │                    │ git: additional local RCE                                   │
│           │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-32465                  │
├───────────┼────────────────┼──────────┤        ├───────────────────┼────────────────────┼─────────────────────────────────────────────────────────────┤
│ libexpat1 │ CVE-2024-45491 │ CRITICAL │        │ 2.5.0-1           │ 2.5.0-1+deb12u1    │ libexpat: Integer Overflow or Wraparound                    │
│           │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-45491                  │
│           ├────────────────┤          │        │                   │                    ├─────────────────────────────────────────────────────────────┤
│           │ CVE-2024-45492 │          │        │                   │                    │ libexpat: integer overflow                                  │
│           │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-45492                  │
│           ├────────────────┼──────────┤        │                   │                    ├─────────────────────────────────────────────────────────────┤
│           │ CVE-2024-45490 │ HIGH     │        │                   │                    │ libexpat: Negative Length Parsing Vulnerability in libexpat │
│           │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-45490                  │
└───────────┴────────────────┴──────────┴────────┴───────────────────┴────────────────────┴─────────────────────────────────────────────────────────────┘

 (gobinary)
===========
Total: 2 (HIGH: 2, CRITICAL: 0)

┌────────────────────────────┬────────────────┬──────────┬────────┬───────────────────┬────────────────┬───────────────────────────────────────────────────────────┐
│          Library           │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version  │                           Title                           │
├────────────────────────────┼────────────────┼──────────┼────────┼───────────────────┼────────────────┼───────────────────────────────────────────────────────────┤
│ golang.org/x/net (kubectl) │ CVE-2024-45338 │ HIGH     │ fixed  │ v0.23.0           │ 0.33.0         │ golang.org/x/net/html: Non-linear parsing of              │
│                            │                │          │        │                   │                │ case-insensitive content in golang.org/x/net/html         │
│                            │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2024-45338                │
├────────────────────────────┼────────────────┤          │        ├───────────────────┼────────────────┼───────────────────────────────────────────────────────────┤
│ stdlib (kubectl)           │ CVE-2024-34156 │          │        │ 1.22.4            │ 1.22.7, 1.23.1 │ encoding/gob: golang: Calling Decoder.Decode on a message │
│                            │                │          │        │                   │                │ which contains deeply nested structures...                │
│                            │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2024-34156                │
└────────────────────────────┴────────────────┴──────────┴────────┴───────────────────┴────────────────┴───────────────────────────────────────────────────────────┘

opt/bitnami/common/bin/yq (gobinary)
====================================
Total: 2 (HIGH: 2, CRITICAL: 0)

┌──────────────────┬────────────────┬──────────┬────────┬───────────────────┬────────────────┬───────────────────────────────────────────────────────────┐
│     Library      │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version  │                           Title                           │
├──────────────────┼────────────────┼──────────┼────────┼───────────────────┼────────────────┼───────────────────────────────────────────────────────────┤
│ golang.org/x/net │ CVE-2024-45338 │ HIGH     │ fixed  │ v0.26.0           │ 0.33.0         │ golang.org/x/net/html: Non-linear parsing of              │
│                  │                │          │        │                   │                │ case-insensitive content in golang.org/x/net/html         │
│                  │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2024-45338                │
├──────────────────┼────────────────┤          │        ├───────────────────┼────────────────┼───────────────────────────────────────────────────────────┤
│ stdlib           │ CVE-2024-34156 │          │        │ v1.21.12          │ 1.22.7, 1.23.1 │ encoding/gob: golang: Calling Decoder.Decode on a message │
│                  │                │          │        │                   │                │ which contains deeply nested structures...                │
│                  │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2024-34156                │
└──────────────────┴────────────────┴──────────┴────────┴───────────────────┴────────────────┴───────────────────────────────────────────────────────────┘

opt/bitnami/kubectl/bin/kubectl (gobinary)
==========================================
Total: 2 (HIGH: 2, CRITICAL: 0)

┌──────────────────┬────────────────┬──────────┬────────┬───────────────────┬────────────────┬───────────────────────────────────────────────────────────┐
│     Library      │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version  │                           Title                           │
├──────────────────┼────────────────┼──────────┼────────┼───────────────────┼────────────────┼───────────────────────────────────────────────────────────┤
│ golang.org/x/net │ CVE-2024-45338 │ HIGH     │ fixed  │ v0.23.0           │ 0.33.0         │ golang.org/x/net/html: Non-linear parsing of              │
│                  │                │          │        │                   │                │ case-insensitive content in golang.org/x/net/html         │
│                  │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2024-45338                │
├──────────────────┼────────────────┤          │        ├───────────────────┼────────────────┼───────────────────────────────────────────────────────────┤
│ stdlib           │ CVE-2024-34156 │          │        │ v1.22.4           │ 1.22.7, 1.23.1 │ encoding/gob: golang: Calling Decoder.Decode on a message │
│                  │                │          │        │                   │                │ which contains deeply nested structures...                │
│                  │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2024-34156                │
└──────────────────┴────────────────┴──────────┴────────┴───────────────────┴────────────────┴───────────────────────────────────────────────────────────┘
