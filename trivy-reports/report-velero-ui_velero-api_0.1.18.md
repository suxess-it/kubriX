
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


docker.io/dserio83/velero-api:0.1.18 (debian 12.6)
==================================================
Total: 8 (HIGH: 6, CRITICAL: 2)

┌───────────────────────┬────────────────┬──────────┬────────┬───────────────────┬──────────────────┬─────────────────────────────────────────────────────────────┐
│        Library        │ Vulnerability  │ Severity │ Status │ Installed Version │  Fixed Version   │                            Title                            │
├───────────────────────┼────────────────┼──────────┼────────┼───────────────────┼──────────────────┼─────────────────────────────────────────────────────────────┤
│ libexpat1             │ CVE-2024-45491 │ CRITICAL │ fixed  │ 2.5.0-1           │ 2.5.0-1+deb12u1  │ libexpat: Integer Overflow or Wraparound                    │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-45491                  │
│                       ├────────────────┤          │        │                   │                  ├─────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-45492 │          │        │                   │                  │ libexpat: integer overflow                                  │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-45492                  │
│                       ├────────────────┼──────────┤        │                   │                  ├─────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-45490 │ HIGH     │        │                   │                  │ libexpat: Negative Length Parsing Vulnerability in libexpat │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-45490                  │
├───────────────────────┼────────────────┤          │        ├───────────────────┼──────────────────┼─────────────────────────────────────────────────────────────┤
│ libpython3.11-minimal │ CVE-2024-6232  │          │        │ 3.11.2-6+deb12u2  │ 3.11.2-6+deb12u4 │ python: cpython: tarfile: ReDos via excessive backtracking  │
│                       │                │          │        │                   │                  │ while parsing header values                                 │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-6232                   │
├───────────────────────┤                │          │        │                   │                  │                                                             │
│ libpython3.11-stdlib  │                │          │        │                   │                  │                                                             │
│                       │                │          │        │                   │                  │                                                             │
│                       │                │          │        │                   │                  │                                                             │
├───────────────────────┼────────────────┤          │        ├───────────────────┼──────────────────┼─────────────────────────────────────────────────────────────┤
│ libsqlite3-0          │ CVE-2023-7104  │          │        │ 3.40.1-2          │ 3.40.1-2+deb12u1 │ sqlite: heap-buffer-overflow at sessionfuzz                 │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2023-7104                   │
├───────────────────────┼────────────────┤          │        ├───────────────────┼──────────────────┼─────────────────────────────────────────────────────────────┤
│ python3.11            │ CVE-2024-6232  │          │        │ 3.11.2-6+deb12u2  │ 3.11.2-6+deb12u4 │ python: cpython: tarfile: ReDos via excessive backtracking  │
│                       │                │          │        │                   │                  │ while parsing header values                                 │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-6232                   │
├───────────────────────┤                │          │        │                   │                  │                                                             │
│ python3.11-minimal    │                │          │        │                   │                  │                                                             │
│                       │                │          │        │                   │                  │                                                             │
│                       │                │          │        │                   │                  │                                                             │
└───────────────────────┴────────────────┴──────────┴────────┴───────────────────┴──────────────────┴─────────────────────────────────────────────────────────────┘

Python (python-pkg)
===================
Total: 3 (HIGH: 3, CRITICAL: 0)

┌─────────────────────────────┬────────────────┬──────────┬────────┬───────────────────┬───────────────┬──────────────────────────────────────────────────────────────┐
│           Library           │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version │                            Title                             │
├─────────────────────────────┼────────────────┼──────────┼────────┼───────────────────┼───────────────┼──────────────────────────────────────────────────────────────┤
│ python-multipart (METADATA) │ CVE-2024-53981 │ HIGH     │ fixed  │ 0.0.9             │ 0.0.18        │ python-multipart: python-multipart has a DoS via deformation │
│                             │                │          │        │                   │               │ `multipart/form-data` boundary                               │
│                             │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-53981                   │
├─────────────────────────────┼────────────────┤          │        ├───────────────────┼───────────────┼──────────────────────────────────────────────────────────────┤
│ setuptools (METADATA)       │ CVE-2024-6345  │          │        │ 65.5.1            │ 70.0.0        │ pypa/setuptools: Remote code execution via download          │
│                             │                │          │        │                   │               │ functions in the package_index module in...                  │
│                             │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-6345                    │
├─────────────────────────────┼────────────────┤          │        ├───────────────────┼───────────────┼──────────────────────────────────────────────────────────────┤
│ starlette (METADATA)        │ CVE-2024-47874 │          │        │ 0.37.2            │ 0.40.0        │ starlette: Starlette Denial of service (DoS) via             │
│                             │                │          │        │                   │               │ multipart/form-data                                          │
│                             │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-47874                   │
└─────────────────────────────┴────────────────┴──────────┴────────┴───────────────────┴───────────────┴──────────────────────────────────────────────────────────────┘

usr/local/bin/kubectl (gobinary)
================================
Total: 2 (HIGH: 2, CRITICAL: 0)

┌──────────────────┬────────────────┬──────────┬────────┬───────────────────┬────────────────┬───────────────────────────────────────────────────────────┐
│     Library      │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version  │                           Title                           │
├──────────────────┼────────────────┼──────────┼────────┼───────────────────┼────────────────┼───────────────────────────────────────────────────────────┤
│ golang.org/x/net │ CVE-2024-45338 │ HIGH     │ fixed  │ v0.23.0           │ 0.33.0         │ golang.org/x/net/html: Non-linear parsing of              │
│                  │                │          │        │                   │                │ case-insensitive content in golang.org/x/net/html         │
│                  │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2024-45338                │
├──────────────────┼────────────────┤          │        ├───────────────────┼────────────────┼───────────────────────────────────────────────────────────┤
│ stdlib           │ CVE-2024-34156 │          │        │ v1.22.5           │ 1.22.7, 1.23.1 │ encoding/gob: golang: Calling Decoder.Decode on a message │
│                  │                │          │        │                   │                │ which contains deeply nested structures...                │
│                  │                │          │        │                   │                │ https://avd.aquasec.com/nvd/cve-2024-34156                │
└──────────────────┴────────────────┴──────────┴────────┴───────────────────┴────────────────┴───────────────────────────────────────────────────────────┘
