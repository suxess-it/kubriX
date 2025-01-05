
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


docker.io/dserio83/velero-watchdog:0.1.6 (debian 12.5)
======================================================
Total: 29 (HIGH: 21, CRITICAL: 8)

┌──────────────────┬────────────────┬──────────┬────────┬───────────────────┬────────────────────┬──────────────────────────────────────────────────────────────┐
│     Library      │ Vulnerability  │ Severity │ Status │ Installed Version │   Fixed Version    │                            Title                             │
├──────────────────┼────────────────┼──────────┼────────┼───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ curl             │ CVE-2024-2398  │ HIGH     │ fixed  │ 7.88.1-10+deb12u5 │ 7.88.1-10+deb12u6  │ curl: HTTP/2 push headers memory-leak                        │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-2398                    │
├──────────────────┼────────────────┼──────────┤        ├───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ git              │ CVE-2024-32002 │ CRITICAL │        │ 1:2.39.2-1.1      │ 1:2.39.5-0+deb12u1 │ git: Recursive clones RCE                                    │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-32002                   │
│                  ├────────────────┼──────────┤        │                   │                    ├──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-25652 │ HIGH     │        │                   │                    │ git: by feeding specially crafted input to `git apply        │
│                  │                │          │        │                   │                    │ --reject`, a path...                                         │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-25652                   │
│                  ├────────────────┤          │        │                   │                    ├──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-29007 │          │        │                   │                    │ git: arbitrary configuration injection when renaming or      │
│                  │                │          │        │                   │                    │ deleting a section from a...                                 │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-29007                   │
│                  ├────────────────┤          │        │                   │                    ├──────────────────────────────────────────────────────────────┤
│                  │ CVE-2024-32004 │          │        │                   │                    │ git: RCE while cloning local repos                           │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-32004                   │
│                  ├────────────────┤          │        │                   │                    ├──────────────────────────────────────────────────────────────┤
│                  │ CVE-2024-32465 │          │        │                   │                    │ git: additional local RCE                                    │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-32465                   │
├──────────────────┼────────────────┼──────────┤        │                   │                    ├──────────────────────────────────────────────────────────────┤
│ git-man          │ CVE-2024-32002 │ CRITICAL │        │                   │                    │ git: Recursive clones RCE                                    │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-32002                   │
│                  ├────────────────┼──────────┤        │                   │                    ├──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-25652 │ HIGH     │        │                   │                    │ git: by feeding specially crafted input to `git apply        │
│                  │                │          │        │                   │                    │ --reject`, a path...                                         │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-25652                   │
│                  ├────────────────┤          │        │                   │                    ├──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-29007 │          │        │                   │                    │ git: arbitrary configuration injection when renaming or      │
│                  │                │          │        │                   │                    │ deleting a section from a...                                 │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-29007                   │
│                  ├────────────────┤          │        │                   │                    ├──────────────────────────────────────────────────────────────┤
│                  │ CVE-2024-32004 │          │        │                   │                    │ git: RCE while cloning local repos                           │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-32004                   │
│                  ├────────────────┤          │        │                   │                    ├──────────────────────────────────────────────────────────────┤
│                  │ CVE-2024-32465 │          │        │                   │                    │ git: additional local RCE                                    │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-32465                   │
├──────────────────┼────────────────┤          │        ├───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ libcurl3-gnutls  │ CVE-2024-2398  │          │        │ 7.88.1-10+deb12u5 │ 7.88.1-10+deb12u6  │ curl: HTTP/2 push headers memory-leak                        │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-2398                    │
├──────────────────┤                │          │        │                   │                    │                                                              │
│ libcurl4         │                │          │        │                   │                    │                                                              │
│                  │                │          │        │                   │                    │                                                              │
├──────────────────┼────────────────┼──────────┤        ├───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ libexpat1        │ CVE-2024-45491 │ CRITICAL │        │ 2.5.0-1           │ 2.5.0-1+deb12u1    │ libexpat: Integer Overflow or Wraparound                     │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-45491                   │
│                  ├────────────────┤          │        │                   │                    ├──────────────────────────────────────────────────────────────┤
│                  │ CVE-2024-45492 │          │        │                   │                    │ libexpat: integer overflow                                   │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-45492                   │
│                  ├────────────────┼──────────┤        │                   │                    ├──────────────────────────────────────────────────────────────┤
│                  │ CVE-2024-45490 │ HIGH     │        │                   │                    │ libexpat: Negative Length Parsing Vulnerability in libexpat  │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-45490                   │
├──────────────────┼────────────────┼──────────┤        ├───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ libgssapi-krb5-2 │ CVE-2024-37371 │ CRITICAL │        │ 1.20.1-2+deb12u1  │ 1.20.1-2+deb12u2   │ krb5: GSS message token handling                             │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-37371                   │
│                  ├────────────────┼──────────┤        │                   │                    ├──────────────────────────────────────────────────────────────┤
│                  │ CVE-2024-37370 │ HIGH     │        │                   │                    │ krb5: GSS message token handling                             │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-37370                   │
├──────────────────┼────────────────┼──────────┤        │                   │                    ├──────────────────────────────────────────────────────────────┤
│ libk5crypto3     │ CVE-2024-37371 │ CRITICAL │        │                   │                    │ krb5: GSS message token handling                             │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-37371                   │
│                  ├────────────────┼──────────┤        │                   │                    ├──────────────────────────────────────────────────────────────┤
│                  │ CVE-2024-37370 │ HIGH     │        │                   │                    │ krb5: GSS message token handling                             │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-37370                   │
├──────────────────┼────────────────┼──────────┤        │                   │                    ├──────────────────────────────────────────────────────────────┤
│ libkrb5-3        │ CVE-2024-37371 │ CRITICAL │        │                   │                    │ krb5: GSS message token handling                             │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-37371                   │
│                  ├────────────────┼──────────┤        │                   │                    ├──────────────────────────────────────────────────────────────┤
│                  │ CVE-2024-37370 │ HIGH     │        │                   │                    │ krb5: GSS message token handling                             │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-37370                   │
├──────────────────┼────────────────┼──────────┤        │                   │                    ├──────────────────────────────────────────────────────────────┤
│ libkrb5support0  │ CVE-2024-37371 │ CRITICAL │        │                   │                    │ krb5: GSS message token handling                             │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-37371                   │
│                  ├────────────────┼──────────┤        │                   │                    ├──────────────────────────────────────────────────────────────┤
│                  │ CVE-2024-37370 │ HIGH     │        │                   │                    │ krb5: GSS message token handling                             │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-37370                   │
├──────────────────┼────────────────┤          │        ├───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ libsqlite3-0     │ CVE-2023-7104  │          │        │ 3.40.1-2          │ 3.40.1-2+deb12u1   │ sqlite: heap-buffer-overflow at sessionfuzz                  │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-7104                    │
├──────────────────┼────────────────┤          │        ├───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ libsystemd0      │ CVE-2023-50387 │          │        │ 252.22-1~deb12u1  │ 252.23-1~deb12u1   │ bind9: KeyTrap - Extreme CPU consumption in DNSSEC validator │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-50387                   │
│                  ├────────────────┤          │        │                   │                    ├──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-50868 │          │        │                   │                    │ bind9: Preparing an NSEC3 closest encloser proof can exhaust │
│                  │                │          │        │                   │                    │ CPU resources                                                │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-50868                   │
├──────────────────┼────────────────┤          │        │                   │                    ├──────────────────────────────────────────────────────────────┤
│ libudev1         │ CVE-2023-50387 │          │        │                   │                    │ bind9: KeyTrap - Extreme CPU consumption in DNSSEC validator │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-50387                   │
│                  ├────────────────┤          │        │                   │                    ├──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-50868 │          │        │                   │                    │ bind9: Preparing an NSEC3 closest encloser proof can exhaust │
│                  │                │          │        │                   │                    │ CPU resources                                                │
│                  │                │          │        │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-50868                   │
└──────────────────┴────────────────┴──────────┴────────┴───────────────────┴────────────────────┴──────────────────────────────────────────────────────────────┘

Python (python-pkg)
===================
Total: 2 (HIGH: 2, CRITICAL: 0)

┌───────────────────────┬────────────────┬──────────┬────────┬───────────────────┬───────────────┬─────────────────────────────────────────────────────┐
│        Library        │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version │                        Title                        │
├───────────────────────┼────────────────┼──────────┼────────┼───────────────────┼───────────────┼─────────────────────────────────────────────────────┤
│ setuptools (METADATA) │ CVE-2024-6345  │ HIGH     │ fixed  │ 65.5.1            │ 70.0.0        │ pypa/setuptools: Remote code execution via download │
│                       │                │          │        │                   │               │ functions in the package_index module in...         │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-6345           │
├───────────────────────┼────────────────┤          │        ├───────────────────┼───────────────┼─────────────────────────────────────────────────────┤
│ starlette (METADATA)  │ CVE-2024-47874 │          │        │ 0.37.2            │ 0.40.0        │ starlette: Starlette Denial of service (DoS) via    │
│                       │                │          │        │                   │               │ multipart/form-data                                 │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-47874          │
└───────────────────────┴────────────────┴──────────┴────────┴───────────────────┴───────────────┴─────────────────────────────────────────────────────┘
