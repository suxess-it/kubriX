
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


appropriate/curl (alpine 3.7.0)
===============================
Total: 28 (HIGH: 6, CRITICAL: 22)

┌───────────────────────┬──────────────────┬──────────┬────────┬───────────────────┬───────────────┬──────────────────────────────────────────────────────────────┐
│        Library        │  Vulnerability   │ Severity │ Status │ Installed Version │ Fixed Version │                            Title                             │
├───────────────────────┼──────────────────┼──────────┼────────┼───────────────────┼───────────────┼──────────────────────────────────────────────────────────────┤
│ curl                  │ CVE-2018-0500    │ CRITICAL │ fixed  │ 7.59.0-r0         │ 7.61.0-r0     │ curl: Heap-based buffer overflow in Curl_smtp_escape_eob()   │
│                       │                  │          │        │                   │               │ when uploading data over SMTP                                │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2018-0500                    │
│                       ├──────────────────┤          │        │                   ├───────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2018-1000300 │          │        │                   │ 7.60.0-r0     │ curl: FTP shutdown response heap-based buffer overflow can   │
│                       │                  │          │        │                   │               │ potentially lead to RCE...                                   │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2018-1000300                 │
│                       ├──────────────────┤          │        │                   │               ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2018-1000301 │          │        │                   │               │ curl: Out-of-bounds heap read when missing RTSP headers      │
│                       │                  │          │        │                   │               │ allows information leak or...                                │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2018-1000301                 │
│                       ├──────────────────┤          │        │                   ├───────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2018-14618   │          │        │                   │ 7.61.1-r0     │ curl: NTLM password overflow via integer overflow            │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2018-14618                   │
│                       ├──────────────────┤          │        │                   ├───────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2018-16839   │          │        │                   │ 7.61.1-r1     │ curl: Integer overflow leading to heap-based buffer overflow │
│                       │                  │          │        │                   │               │ in Curl_sasl_create_plain_message()                          │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2018-16839                   │
│                       ├──────────────────┤          │        │                   │               ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2018-16840   │          │        │                   │               │ curl: Use-after-free when closing "easy" handle in           │
│                       │                  │          │        │                   │               │ Curl_close()                                                 │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2018-16840                   │
│                       ├──────────────────┤          │        │                   │               ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2018-16842   │          │        │                   │               │ curl: Heap-based buffer over-read in the curl tool warning   │
│                       │                  │          │        │                   │               │ formatting                                                   │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2018-16842                   │
│                       ├──────────────────┤          │        │                   ├───────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2019-3822    │          │        │                   │ 7.61.1-r2     │ curl: NTLMv2 type-3 header stack buffer overflow             │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2019-3822                    │
│                       ├──────────────────┤          │        │                   ├───────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2019-5481    │          │        │                   │ 7.61.1-r3     │ curl: double free due to subsequent call of realloc()        │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2019-5481                    │
│                       ├──────────────────┤          │        │                   │               ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2019-5482    │          │        │                   │               │ curl: heap buffer overflow in function tftp_receive_packet() │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2019-5482                    │
│                       ├──────────────────┼──────────┤        │                   ├───────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2018-16890   │ HIGH     │        │                   │ 7.61.1-r2     │ curl: NTLM type-2 heap out-of-bounds buffer read             │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2018-16890                   │
│                       ├──────────────────┤          │        │                   │               ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2019-3823    │          │        │                   │               │ curl: SMTP end-of-response out-of-bounds read                │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2019-3823                    │
├───────────────────────┼──────────────────┼──────────┤        │                   ├───────────────┼──────────────────────────────────────────────────────────────┤
│ libcurl               │ CVE-2018-0500    │ CRITICAL │        │                   │ 7.61.0-r0     │ curl: Heap-based buffer overflow in Curl_smtp_escape_eob()   │
│                       │                  │          │        │                   │               │ when uploading data over SMTP                                │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2018-0500                    │
│                       ├──────────────────┤          │        │                   ├───────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2018-1000300 │          │        │                   │ 7.60.0-r0     │ curl: FTP shutdown response heap-based buffer overflow can   │
│                       │                  │          │        │                   │               │ potentially lead to RCE...                                   │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2018-1000300                 │
│                       ├──────────────────┤          │        │                   │               ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2018-1000301 │          │        │                   │               │ curl: Out-of-bounds heap read when missing RTSP headers      │
│                       │                  │          │        │                   │               │ allows information leak or...                                │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2018-1000301                 │
│                       ├──────────────────┤          │        │                   ├───────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2018-14618   │          │        │                   │ 7.61.1-r0     │ curl: NTLM password overflow via integer overflow            │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2018-14618                   │
│                       ├──────────────────┤          │        │                   ├───────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2018-16839   │          │        │                   │ 7.61.1-r1     │ curl: Integer overflow leading to heap-based buffer overflow │
│                       │                  │          │        │                   │               │ in Curl_sasl_create_plain_message()                          │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2018-16839                   │
│                       ├──────────────────┤          │        │                   │               ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2018-16840   │          │        │                   │               │ curl: Use-after-free when closing "easy" handle in           │
│                       │                  │          │        │                   │               │ Curl_close()                                                 │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2018-16840                   │
│                       ├──────────────────┤          │        │                   │               ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2018-16842   │          │        │                   │               │ curl: Heap-based buffer over-read in the curl tool warning   │
│                       │                  │          │        │                   │               │ formatting                                                   │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2018-16842                   │
│                       ├──────────────────┤          │        │                   ├───────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2019-3822    │          │        │                   │ 7.61.1-r2     │ curl: NTLMv2 type-3 header stack buffer overflow             │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2019-3822                    │
│                       ├──────────────────┤          │        │                   ├───────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2019-5481    │          │        │                   │ 7.61.1-r3     │ curl: double free due to subsequent call of realloc()        │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2019-5481                    │
│                       ├──────────────────┤          │        │                   │               ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2019-5482    │          │        │                   │               │ curl: heap buffer overflow in function tftp_receive_packet() │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2019-5482                    │
│                       ├──────────────────┼──────────┤        │                   ├───────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2018-16890   │ HIGH     │        │                   │ 7.61.1-r2     │ curl: NTLM type-2 heap out-of-bounds buffer read             │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2018-16890                   │
│                       ├──────────────────┤          │        │                   │               ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2019-3823    │          │        │                   │               │ curl: SMTP end-of-response out-of-bounds read                │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2019-3823                    │
├───────────────────────┼──────────────────┤          │        ├───────────────────┼───────────────┼──────────────────────────────────────────────────────────────┤
│ libressl2.6-libcrypto │ CVE-2018-0732    │          │        │ 2.6.3-r0          │ 2.6.5-r0      │ openssl: Malicious server can send large prime to client     │
│                       │                  │          │        │                   │               │ during DH(E) TLS...                                          │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2018-0732                    │
├───────────────────────┤                  │          │        │                   │               │                                                              │
│ libressl2.6-libssl    │                  │          │        │                   │               │                                                              │
│                       │                  │          │        │                   │               │                                                              │
│                       │                  │          │        │                   │               │                                                              │
├───────────────────────┼──────────────────┼──────────┤        ├───────────────────┼───────────────┼──────────────────────────────────────────────────────────────┤
│ musl                  │ CVE-2019-14697   │ CRITICAL │        │ 1.1.18-r2         │ 1.1.18-r4     │ musl libc through 1.1.23 has an x87 floating-point stack     │
│                       │                  │          │        │                   │               │ adjustment im ......                                         │
│                       │                  │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2019-14697                   │
├───────────────────────┤                  │          │        │                   │               │                                                              │
│ musl-utils            │                  │          │        │                   │               │                                                              │
│                       │                  │          │        │                   │               │                                                              │
│                       │                  │          │        │                   │               │                                                              │
└───────────────────────┴──────────────────┴──────────┴────────┴───────────────────┴───────────────┴──────────────────────────────────────────────────────────────┘
