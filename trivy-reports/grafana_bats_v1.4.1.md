
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


docker.io/bats/bats:v1.4.1 (alpine 3.15.4)
==========================================
Total: 16 (HIGH: 15, CRITICAL: 1)

┌───────────────────────┬────────────────┬──────────┬────────┬───────────────────┬──────────────────┬──────────────────────────────────────────────────────────────┐
│        Library        │ Vulnerability  │ Severity │ Status │ Installed Version │  Fixed Version   │                            Title                             │
├───────────────────────┼────────────────┼──────────┼────────┼───────────────────┼──────────────────┼──────────────────────────────────────────────────────────────┤
│ libcrypto1.1          │ CVE-2022-4450  │ HIGH     │ fixed  │ 1.1.1n-r0         │ 1.1.1t-r0        │ openssl: double free after calling PEM_read_bio_ex           │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2022-4450                    │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2023-0215  │          │        │                   │                  │ openssl: use-after-free following BIO_new_NDEF               │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2023-0215                    │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2023-0286  │          │        │                   │                  │ openssl: X.400 address type confusion in X.509 GeneralName   │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2023-0286                    │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2023-0464  │          │        │                   │ 1.1.1t-r2        │ openssl: Denial of service by excessive resource usage in    │
│                       │                │          │        │                   │                  │ verifying X509 policy...                                     │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2023-0464                    │
├───────────────────────┼────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│ libssl1.1             │ CVE-2022-4450  │          │        │                   │ 1.1.1t-r0        │ openssl: double free after calling PEM_read_bio_ex           │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2022-4450                    │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2023-0215  │          │        │                   │                  │ openssl: use-after-free following BIO_new_NDEF               │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2023-0215                    │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2023-0286  │          │        │                   │                  │ openssl: X.400 address type confusion in X.509 GeneralName   │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2023-0286                    │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2023-0464  │          │        │                   │ 1.1.1t-r2        │ openssl: Denial of service by excessive resource usage in    │
│                       │                │          │        │                   │                  │ verifying X509 policy...                                     │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2023-0464                    │
├───────────────────────┼────────────────┤          │        ├───────────────────┼──────────────────┼──────────────────────────────────────────────────────────────┤
│ ncurses               │ CVE-2022-29458 │          │        │ 6.3_p20211120-r0  │ 6.3_p20211120-r1 │ ncurses: segfaulting OOB read                                │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2022-29458                   │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2023-29491 │          │        │                   │ 6.3_p20211120-r2 │ ncurses: Local users can trigger security-relevant memory    │
│                       │                │          │        │                   │                  │ corruption via malformed data                                │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2023-29491                   │
├───────────────────────┼────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│ ncurses-libs          │ CVE-2022-29458 │          │        │                   │ 6.3_p20211120-r1 │ ncurses: segfaulting OOB read                                │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2022-29458                   │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2023-29491 │          │        │                   │ 6.3_p20211120-r2 │ ncurses: Local users can trigger security-relevant memory    │
│                       │                │          │        │                   │                  │ corruption via malformed data                                │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2023-29491                   │
├───────────────────────┼────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│ ncurses-terminfo-base │ CVE-2022-29458 │          │        │                   │ 6.3_p20211120-r1 │ ncurses: segfaulting OOB read                                │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2022-29458                   │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2023-29491 │          │        │                   │ 6.3_p20211120-r2 │ ncurses: Local users can trigger security-relevant memory    │
│                       │                │          │        │                   │                  │ corruption via malformed data                                │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2023-29491                   │
├───────────────────────┼────────────────┤          │        ├───────────────────┼──────────────────┼──────────────────────────────────────────────────────────────┤
│ perl                  │ CVE-2023-47038 │          │        │ 5.34.0-r1         │ 5.34.2-r0        │ perl: Write past buffer end via illegal user-defined Unicode │
│                       │                │          │        │                   │                  │ property                                                     │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2023-47038                   │
├───────────────────────┼────────────────┼──────────┤        ├───────────────────┼──────────────────┼──────────────────────────────────────────────────────────────┤
│ zlib                  │ CVE-2022-37434 │ CRITICAL │        │ 1.2.12-r0         │ 1.2.12-r2        │ zlib: heap-based buffer over-read and overflow in inflate()  │
│                       │                │          │        │                   │                  │ in inflate.c via a...                                        │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2022-37434                   │
└───────────────────────┴────────────────┴──────────┴────────┴───────────────────┴──────────────────┴──────────────────────────────────────────────────────────────┘
