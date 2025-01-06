
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


alpine/k8s:1.26.9 (alpine 3.18.4)
=================================
Total: 25 (HIGH: 20, CRITICAL: 5)

┌──────────────────────┬────────────────┬──────────┬────────┬───────────────────┬───────────────┬─────────────────────────────────────────────────────────────┐
│       Library        │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version │                            Title                            │
├──────────────────────┼────────────────┼──────────┼────────┼───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ curl                 │ CVE-2023-38545 │ CRITICAL │ fixed  │ 8.3.0-r0          │ 8.4.0-r0      │ curl: heap based buffer overflow in the SOCKS5 proxy        │
│                      │                │          │        │                   │               │ handshake                                                   │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-38545                  │
│                      ├────────────────┼──────────┤        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│                      │ CVE-2024-2398  │ HIGH     │        │                   │ 8.7.1-r0      │ curl: HTTP/2 push headers memory-leak                       │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-2398                   │
│                      ├────────────────┤          │        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│                      │ CVE-2024-6197  │          │        │                   │ 8.9.0-r0      │ curl: freeing stack buffer in utf8asn1str                   │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-6197                   │
├──────────────────────┼────────────────┼──────────┤        ├───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ git                  │ CVE-2024-32002 │ CRITICAL │        │ 2.40.1-r0         │ 2.40.3-r0     │ git: Recursive clones RCE                                   │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-32002                  │
│                      ├────────────────┼──────────┤        │                   │               ├─────────────────────────────────────────────────────────────┤
│                      │ CVE-2024-32004 │ HIGH     │        │                   │               │ git: RCE while cloning local repos                          │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-32004                  │
│                      ├────────────────┤          │        │                   │               ├─────────────────────────────────────────────────────────────┤
│                      │ CVE-2024-32465 │          │        │                   │               │ git: additional local RCE                                   │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-32465                  │
├──────────────────────┼────────────────┤          │        ├───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ libcrypto3           │ CVE-2023-5363  │          │        │ 3.1.3-r0          │ 3.1.4-r0      │ openssl: Incorrect cipher key and IV length processing      │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-5363                   │
├──────────────────────┼────────────────┼──────────┤        ├───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ libcurl              │ CVE-2023-38545 │ CRITICAL │        │ 8.3.0-r0          │ 8.4.0-r0      │ curl: heap based buffer overflow in the SOCKS5 proxy        │
│                      │                │          │        │                   │               │ handshake                                                   │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-38545                  │
│                      ├────────────────┼──────────┤        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│                      │ CVE-2024-2398  │ HIGH     │        │                   │ 8.7.1-r0      │ curl: HTTP/2 push headers memory-leak                       │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-2398                   │
│                      ├────────────────┤          │        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│                      │ CVE-2024-6197  │          │        │                   │ 8.9.0-r0      │ curl: freeing stack buffer in utf8asn1str                   │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-6197                   │
├──────────────────────┼────────────────┼──────────┤        ├───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ libexpat             │ CVE-2024-45491 │ CRITICAL │        │ 2.5.0-r1          │ 2.6.3-r0      │ libexpat: Integer Overflow or Wraparound                    │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-45491                  │
│                      ├────────────────┤          │        │                   │               ├─────────────────────────────────────────────────────────────┤
│                      │ CVE-2024-45492 │          │        │                   │               │ libexpat: integer overflow                                  │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-45492                  │
│                      ├────────────────┼──────────┤        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│                      │ CVE-2023-52425 │ HIGH     │        │                   │ 2.6.0-r0      │ expat: parsing large tokens can trigger a denial of service │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-52425                  │
│                      ├────────────────┤          │        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│                      │ CVE-2024-28757 │          │        │                   │ 2.6.2-r0      │ expat: XML Entity Expansion                                 │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-28757                  │
│                      ├────────────────┤          │        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│                      │ CVE-2024-45490 │          │        │                   │ 2.6.3-r0      │ libexpat: Negative Length Parsing Vulnerability in libexpat │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-45490                  │
├──────────────────────┼────────────────┤          │        ├───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ libssl3              │ CVE-2023-5363  │          │        │ 3.1.3-r0          │ 3.1.4-r0      │ openssl: Incorrect cipher key and IV length processing      │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-5363                   │
├──────────────────────┼────────────────┤          │        ├───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ libxml2              │ CVE-2024-25062 │          │        │ 2.11.4-r0         │ 2.11.7-r0     │ libxml2: use-after-free in XMLReader                        │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-25062                  │
├──────────────────────┼────────────────┤          │        ├───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ nghttp2-libs         │ CVE-2023-44487 │          │        │ 1.55.1-r0         │ 1.57.0-r0     │ HTTP/2: Multiple HTTP/2 enabled web servers are vulnerable  │
│                      │                │          │        │                   │               │ to a DDoS attack...                                         │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-44487                  │
├──────────────────────┼────────────────┤          │        ├───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ python3              │ CVE-2024-6232  │          │        │ 3.11.6-r0         │ 3.11.10-r0    │ python: cpython: tarfile: ReDos via excessive backtracking  │
│                      │                │          │        │                   │               │ while parsing header values                                 │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-6232                   │
│                      ├────────────────┤          │        │                   │               ├─────────────────────────────────────────────────────────────┤
│                      │ CVE-2024-7592  │          │        │                   │               │ cpython: python: Uncontrolled CPU resource consumption when │
│                      │                │          │        │                   │               │ in http.cookies module                                      │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-7592                   │
├──────────────────────┼────────────────┤          │        │                   │               ├─────────────────────────────────────────────────────────────┤
│ python3-pyc          │ CVE-2024-6232  │          │        │                   │               │ python: cpython: tarfile: ReDos via excessive backtracking  │
│                      │                │          │        │                   │               │ while parsing header values                                 │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-6232                   │
│                      ├────────────────┤          │        │                   │               ├─────────────────────────────────────────────────────────────┤
│                      │ CVE-2024-7592  │          │        │                   │               │ cpython: python: Uncontrolled CPU resource consumption when │
│                      │                │          │        │                   │               │ in http.cookies module                                      │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-7592                   │
├──────────────────────┼────────────────┤          │        │                   │               ├─────────────────────────────────────────────────────────────┤
│ python3-pycache-pyc0 │ CVE-2024-6232  │          │        │                   │               │ python: cpython: tarfile: ReDos via excessive backtracking  │
│                      │                │          │        │                   │               │ while parsing header values                                 │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-6232                   │
│                      ├────────────────┤          │        │                   │               ├─────────────────────────────────────────────────────────────┤
│                      │ CVE-2024-7592  │          │        │                   │               │ cpython: python: Uncontrolled CPU resource consumption when │
│                      │                │          │        │                   │               │ in http.cookies module                                      │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-7592                   │
├──────────────────────┼────────────────┤          │        ├───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ sqlite-libs          │ CVE-2023-7104  │          │        │ 3.41.2-r2         │ 3.41.2-r3     │ sqlite: heap-buffer-overflow at sessionfuzz                 │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-7104                   │
└──────────────────────┴────────────────┴──────────┴────────┴───────────────────┴───────────────┴─────────────────────────────────────────────────────────────┘

Python (python-pkg)
===================
Total: 2 (HIGH: 2, CRITICAL: 0)

┌───────────────────────┬────────────────┬──────────┬────────┬───────────────────┬───────────────┬───────────────────────────────────────────────────────┐
│        Library        │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version │                         Title                         │
├───────────────────────┼────────────────┼──────────┼────────┼───────────────────┼───────────────┼───────────────────────────────────────────────────────┤
│ setuptools (METADATA) │ CVE-2022-40897 │ HIGH     │ fixed  │ 65.5.0            │ 65.5.1        │ pypa-setuptools: Regular Expression Denial of Service │
│                       │                │          │        │                   │               │ (ReDoS) in package_index.py                           │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2022-40897            │
│                       ├────────────────┤          │        │                   ├───────────────┼───────────────────────────────────────────────────────┤
│                       │ CVE-2024-6345  │          │        │                   │ 70.0.0        │ pypa/setuptools: Remote code execution via download   │
│                       │                │          │        │                   │               │ functions in the package_index module in...           │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-6345             │
└───────────────────────┴────────────────┴──────────┴────────┴───────────────────┴───────────────┴───────────────────────────────────────────────────────┘

krew-linux_amd64 (gobinary)
===========================
Total: 7 (HIGH: 6, CRITICAL: 1)

┌──────────────────┬────────────────┬──────────┬────────┬───────────────────┬──────────────────────────────────┬──────────────────────────────────────────────────────────────┐
│     Library      │ Vulnerability  │ Severity │ Status │ Installed Version │          Fixed Version           │                            Title                             │
├──────────────────┼────────────────┼──────────┼────────┼───────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ golang.org/x/net │ CVE-2023-39325 │ HIGH     │ fixed  │ v0.12.0           │ 0.17.0                           │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                  │                │          │        │                   │                                  │ excessive work (CVE-2023-44487)                              │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                  ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2024-45338 │          │        │                   │ 0.33.0                           │ golang.org/x/net/html: Non-linear parsing of                 │
│                  │                │          │        │                   │                                  │ case-insensitive content in golang.org/x/net/html            │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-45338                   │
├──────────────────┼────────────────┼──────────┤        ├───────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ stdlib           │ CVE-2024-24790 │ CRITICAL │        │ v1.20.5           │ 1.21.11, 1.22.4                  │ golang: net/netip: Unexpected behavior from Is methods for   │
│                  │                │          │        │                   │                                  │ IPv4-mapped IPv6 addresses                                   │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-24790                   │
│                  ├────────────────┼──────────┤        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-39325 │ HIGH     │        │                   │ 1.20.10, 1.21.3                  │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                  │                │          │        │                   │                                  │ excessive work (CVE-2023-44487)                              │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                  ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-45283 │          │        │                   │ 1.20.11, 1.21.4, 1.20.12, 1.21.5 │ The filepath package does not recognize paths with a \??\    │
│                  │                │          │        │                   │                                  │ prefix as...                                                 │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-45283                   │
│                  ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-45288 │          │        │                   │ 1.21.9, 1.22.2                   │ golang: net/http, x/net/http2: unlimited number of           │
│                  │                │          │        │                   │                                  │ CONTINUATION frames causes DoS                               │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-45288                   │
│                  ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2024-34156 │          │        │                   │ 1.22.7, 1.23.1                   │ encoding/gob: golang: Calling Decoder.Decode on a message    │
│                  │                │          │        │                   │                                  │ which contains deeply nested structures...                   │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-34156                   │
└──────────────────┴────────────────┴──────────┴────────┴───────────────────┴──────────────────────────────────┴──────────────────────────────────────────────────────────────┘

root/.krew/store/krew/v0.4.4/krew (gobinary)
============================================
Total: 7 (HIGH: 6, CRITICAL: 1)

┌──────────────────┬────────────────┬──────────┬────────┬───────────────────┬──────────────────────────────────┬──────────────────────────────────────────────────────────────┐
│     Library      │ Vulnerability  │ Severity │ Status │ Installed Version │          Fixed Version           │                            Title                             │
├──────────────────┼────────────────┼──────────┼────────┼───────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ golang.org/x/net │ CVE-2023-39325 │ HIGH     │ fixed  │ v0.12.0           │ 0.17.0                           │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                  │                │          │        │                   │                                  │ excessive work (CVE-2023-44487)                              │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                  ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2024-45338 │          │        │                   │ 0.33.0                           │ golang.org/x/net/html: Non-linear parsing of                 │
│                  │                │          │        │                   │                                  │ case-insensitive content in golang.org/x/net/html            │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-45338                   │
├──────────────────┼────────────────┼──────────┤        ├───────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ stdlib           │ CVE-2024-24790 │ CRITICAL │        │ v1.20.5           │ 1.21.11, 1.22.4                  │ golang: net/netip: Unexpected behavior from Is methods for   │
│                  │                │          │        │                   │                                  │ IPv4-mapped IPv6 addresses                                   │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-24790                   │
│                  ├────────────────┼──────────┤        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-39325 │ HIGH     │        │                   │ 1.20.10, 1.21.3                  │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                  │                │          │        │                   │                                  │ excessive work (CVE-2023-44487)                              │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                  ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-45283 │          │        │                   │ 1.20.11, 1.21.4, 1.20.12, 1.21.5 │ The filepath package does not recognize paths with a \??\    │
│                  │                │          │        │                   │                                  │ prefix as...                                                 │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-45283                   │
│                  ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-45288 │          │        │                   │ 1.21.9, 1.22.2                   │ golang: net/http, x/net/http2: unlimited number of           │
│                  │                │          │        │                   │                                  │ CONTINUATION frames causes DoS                               │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-45288                   │
│                  ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2024-34156 │          │        │                   │ 1.22.7, 1.23.1                   │ encoding/gob: golang: Calling Decoder.Decode on a message    │
│                  │                │          │        │                   │                                  │ which contains deeply nested structures...                   │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-34156                   │
└──────────────────┴────────────────┴──────────┴────────┴───────────────────┴──────────────────────────────────┴──────────────────────────────────────────────────────────────┘

root/.local/share/helm/plugins/helm-diff/bin/diff (gobinary)
============================================================
Total: 16 (HIGH: 12, CRITICAL: 4)

┌──────────────────────────┬─────────────────────┬──────────┬────────┬────────────────────────┬──────────────────────────────────┬──────────────────────────────────────────────────────────────┐
│         Library          │    Vulnerability    │ Severity │ Status │   Installed Version    │          Fixed Version           │                            Title                             │
├──────────────────────────┼─────────────────────┼──────────┼────────┼────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ github.com/docker/docker │ CVE-2024-41110      │ CRITICAL │ fixed  │ v20.10.24+incompatible │ 23.0.15, 26.1.5, 27.1.1, 25.0.6  │ moby: Authz zero length regression                           │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2024-41110                   │
├──────────────────────────┼─────────────────────┤          │        ├────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ golang.org/x/crypto      │ CVE-2024-45337      │          │        │ v0.5.0                 │ 0.31.0                           │ golang.org/x/crypto/ssh: Misuse of                           │
│                          │                     │          │        │                        │                                  │ ServerConfig.PublicKeyCallback may cause authorization       │
│                          │                     │          │        │                        │                                  │ bypass in golang.org/x/crypto                                │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2024-45337                   │
├──────────────────────────┼─────────────────────┼──────────┤        ├────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ golang.org/x/net         │ CVE-2023-39325      │ HIGH     │        │ v0.9.0                 │ 0.17.0                           │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                          │                     │          │        │                        │                                  │ excessive work (CVE-2023-44487)                              │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                          ├─────────────────────┤          │        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                          │ CVE-2024-45338      │          │        │                        │ 0.33.0                           │ golang.org/x/net/html: Non-linear parsing of                 │
│                          │                     │          │        │                        │                                  │ case-insensitive content in golang.org/x/net/html            │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2024-45338                   │
├──────────────────────────┼─────────────────────┤          │        ├────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ google.golang.org/grpc   │ GHSA-m425-mq94-257g │          │        │ v1.53.0                │ 1.56.3, 1.57.1, 1.58.3           │ gRPC-Go HTTP/2 Rapid Reset vulnerability                     │
│                          │                     │          │        │                        │                                  │ https://github.com/advisories/GHSA-m425-mq94-257g            │
├──────────────────────────┼─────────────────────┤          │        ├────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ helm.sh/helm/v3          │ CVE-2024-26147      │          │        │ v3.11.3                │ 3.14.2                           │ helm: Missing YAML Content Leads To Panic                    │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2024-26147                   │
├──────────────────────────┼─────────────────────┼──────────┤        ├────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ stdlib                   │ CVE-2023-24540      │ CRITICAL │        │ v1.19.8                │ 1.19.9, 1.20.4                   │ golang: html/template: improper handling of JavaScript       │
│                          │                     │          │        │                        │                                  │ whitespace                                                   │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-24540                   │
│                          ├─────────────────────┤          │        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                          │ CVE-2024-24790      │          │        │                        │ 1.21.11, 1.22.4                  │ golang: net/netip: Unexpected behavior from Is methods for   │
│                          │                     │          │        │                        │                                  │ IPv4-mapped IPv6 addresses                                   │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2024-24790                   │
│                          ├─────────────────────┼──────────┤        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                          │ CVE-2023-24539      │ HIGH     │        │                        │ 1.19.9, 1.20.4                   │ golang: html/template: improper sanitization of CSS values   │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-24539                   │
│                          ├─────────────────────┤          │        │                        │                                  ├──────────────────────────────────────────────────────────────┤
│                          │ CVE-2023-29400      │          │        │                        │                                  │ golang: html/template: improper handling of empty HTML       │
│                          │                     │          │        │                        │                                  │ attributes                                                   │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-29400                   │
│                          ├─────────────────────┤          │        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                          │ CVE-2023-29403      │          │        │                        │ 1.19.10, 1.20.5                  │ golang: runtime: unexpected behavior of setuid/setgid        │
│                          │                     │          │        │                        │                                  │ binaries                                                     │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-29403                   │
│                          ├─────────────────────┤          │        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                          │ CVE-2023-39325      │          │        │                        │ 1.20.10, 1.21.3                  │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                          │                     │          │        │                        │                                  │ excessive work (CVE-2023-44487)                              │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                          ├─────────────────────┤          │        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                          │ CVE-2023-45283      │          │        │                        │ 1.20.11, 1.21.4, 1.20.12, 1.21.5 │ The filepath package does not recognize paths with a \??\    │
│                          │                     │          │        │                        │                                  │ prefix as...                                                 │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-45283                   │
│                          ├─────────────────────┤          │        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                          │ CVE-2023-45287      │          │        │                        │ 1.20.0                           │ golang: crypto/tls: Timing Side Channel attack in RSA based  │
│                          │                     │          │        │                        │                                  │ TLS key exchanges....                                        │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-45287                   │
│                          ├─────────────────────┤          │        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                          │ CVE-2023-45288      │          │        │                        │ 1.21.9, 1.22.2                   │ golang: net/http, x/net/http2: unlimited number of           │
│                          │                     │          │        │                        │                                  │ CONTINUATION frames causes DoS                               │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-45288                   │
│                          ├─────────────────────┤          │        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                          │ CVE-2024-34156      │          │        │                        │ 1.22.7, 1.23.1                   │ encoding/gob: golang: Calling Decoder.Decode on a message    │
│                          │                     │          │        │                        │                                  │ which contains deeply nested structures...                   │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2024-34156                   │
└──────────────────────────┴─────────────────────┴──────────┴────────┴────────────────────────┴──────────────────────────────────┴──────────────────────────────────────────────────────────────┘

root/.local/share/helm/plugins/helm-push/bin/helm-cm-push (gobinary)
====================================================================
Total: 13 (HIGH: 10, CRITICAL: 3)

┌────────────────────────────────┬─────────────────────┬──────────┬────────┬────────────────────────┬──────────────────────────────────┬──────────────────────────────────────────────────────────────┐
│            Library             │    Vulnerability    │ Severity │ Status │   Installed Version    │          Fixed Version           │                            Title                             │
├────────────────────────────────┼─────────────────────┼──────────┼────────┼────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ github.com/docker/distribution │ CVE-2023-2253       │ HIGH     │ fixed  │ v2.8.1+incompatible    │ 2.8.2-beta.1                     │ distribution/distribution: DoS from malicious API request    │
│                                │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-2253                    │
├────────────────────────────────┼─────────────────────┼──────────┤        ├────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ github.com/docker/docker       │ CVE-2024-41110      │ CRITICAL │        │ v20.10.24+incompatible │ 23.0.15, 26.1.5, 27.1.1, 25.0.6  │ moby: Authz zero length regression                           │
│                                │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2024-41110                   │
├────────────────────────────────┼─────────────────────┤          │        ├────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ golang.org/x/crypto            │ CVE-2024-45337      │          │        │ v0.5.0                 │ 0.31.0                           │ golang.org/x/crypto/ssh: Misuse of                           │
│                                │                     │          │        │                        │                                  │ ServerConfig.PublicKeyCallback may cause authorization       │
│                                │                     │          │        │                        │                                  │ bypass in golang.org/x/crypto                                │
│                                │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2024-45337                   │
├────────────────────────────────┼─────────────────────┼──────────┤        ├────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ golang.org/x/net               │ CVE-2023-39325      │ HIGH     │        │ v0.9.0                 │ 0.17.0                           │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                                │                     │          │        │                        │                                  │ excessive work (CVE-2023-44487)                              │
│                                │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                                ├─────────────────────┤          │        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                │ CVE-2024-45338      │          │        │                        │ 0.33.0                           │ golang.org/x/net/html: Non-linear parsing of                 │
│                                │                     │          │        │                        │                                  │ case-insensitive content in golang.org/x/net/html            │
│                                │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2024-45338                   │
├────────────────────────────────┼─────────────────────┤          │        ├────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ google.golang.org/grpc         │ GHSA-m425-mq94-257g │          │        │ v1.49.0                │ 1.56.3, 1.57.1, 1.58.3           │ gRPC-Go HTTP/2 Rapid Reset vulnerability                     │
│                                │                     │          │        │                        │                                  │ https://github.com/advisories/GHSA-m425-mq94-257g            │
├────────────────────────────────┼─────────────────────┤          │        ├────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ helm.sh/helm/v3                │ CVE-2024-26147      │          │        │ v3.11.2                │ 3.14.2                           │ helm: Missing YAML Content Leads To Panic                    │
│                                │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2024-26147                   │
├────────────────────────────────┼─────────────────────┼──────────┤        ├────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ stdlib                         │ CVE-2024-24790      │ CRITICAL │        │ v1.20.4                │ 1.21.11, 1.22.4                  │ golang: net/netip: Unexpected behavior from Is methods for   │
│                                │                     │          │        │                        │                                  │ IPv4-mapped IPv6 addresses                                   │
│                                │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2024-24790                   │
│                                ├─────────────────────┼──────────┤        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                │ CVE-2023-29403      │ HIGH     │        │                        │ 1.19.10, 1.20.5                  │ golang: runtime: unexpected behavior of setuid/setgid        │
│                                │                     │          │        │                        │                                  │ binaries                                                     │
│                                │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-29403                   │
│                                ├─────────────────────┤          │        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                │ CVE-2023-39325      │          │        │                        │ 1.20.10, 1.21.3                  │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                                │                     │          │        │                        │                                  │ excessive work (CVE-2023-44487)                              │
│                                │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                                ├─────────────────────┤          │        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                │ CVE-2023-45283      │          │        │                        │ 1.20.11, 1.21.4, 1.20.12, 1.21.5 │ The filepath package does not recognize paths with a \??\    │
│                                │                     │          │        │                        │                                  │ prefix as...                                                 │
│                                │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-45283                   │
│                                ├─────────────────────┤          │        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                │ CVE-2023-45288      │          │        │                        │ 1.21.9, 1.22.2                   │ golang: net/http, x/net/http2: unlimited number of           │
│                                │                     │          │        │                        │                                  │ CONTINUATION frames causes DoS                               │
│                                │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-45288                   │
│                                ├─────────────────────┤          │        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                │ CVE-2024-34156      │          │        │                        │ 1.22.7, 1.23.1                   │ encoding/gob: golang: Calling Decoder.Decode on a message    │
│                                │                     │          │        │                        │                                  │ which contains deeply nested structures...                   │
│                                │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2024-34156                   │
└────────────────────────────────┴─────────────────────┴──────────┴────────┴────────────────────────┴──────────────────────────────────┴──────────────────────────────────────────────────────────────┘

root/.local/share/helm/plugins/helm-unittest/untt (gobinary)
============================================================
Total: 9 (HIGH: 7, CRITICAL: 2)

┌─────────────────────┬────────────────┬──────────┬────────┬───────────────────┬──────────────────────────────────┬──────────────────────────────────────────────────────────────┐
│       Library       │ Vulnerability  │ Severity │ Status │ Installed Version │          Fixed Version           │                            Title                             │
├─────────────────────┼────────────────┼──────────┼────────┼───────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ golang.org/x/crypto │ CVE-2024-45337 │ CRITICAL │ fixed  │ v0.8.0            │ 0.31.0                           │ golang.org/x/crypto/ssh: Misuse of                           │
│                     │                │          │        │                   │                                  │ ServerConfig.PublicKeyCallback may cause authorization       │
│                     │                │          │        │                   │                                  │ bypass in golang.org/x/crypto                                │
│                     │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-45337                   │
├─────────────────────┼────────────────┼──────────┤        ├───────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ golang.org/x/net    │ CVE-2023-39325 │ HIGH     │        │ v0.10.0           │ 0.17.0                           │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                     │                │          │        │                   │                                  │ excessive work (CVE-2023-44487)                              │
│                     │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                     ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                     │ CVE-2024-45338 │          │        │                   │ 0.33.0                           │ golang.org/x/net/html: Non-linear parsing of                 │
│                     │                │          │        │                   │                                  │ case-insensitive content in golang.org/x/net/html            │
│                     │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-45338                   │
├─────────────────────┼────────────────┤          │        ├───────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ helm.sh/helm/v3     │ CVE-2024-26147 │          │        │ v3.12.2           │ 3.14.2                           │ helm: Missing YAML Content Leads To Panic                    │
│                     │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-26147                   │
├─────────────────────┼────────────────┼──────────┤        ├───────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ stdlib              │ CVE-2024-24790 │ CRITICAL │        │ v1.21.1           │ 1.21.11, 1.22.4                  │ golang: net/netip: Unexpected behavior from Is methods for   │
│                     │                │          │        │                   │                                  │ IPv4-mapped IPv6 addresses                                   │
│                     │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-24790                   │
│                     ├────────────────┼──────────┤        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                     │ CVE-2023-39325 │ HIGH     │        │                   │ 1.20.10, 1.21.3                  │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                     │                │          │        │                   │                                  │ excessive work (CVE-2023-44487)                              │
│                     │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                     ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                     │ CVE-2023-45283 │          │        │                   │ 1.20.11, 1.21.4, 1.20.12, 1.21.5 │ The filepath package does not recognize paths with a \??\    │
│                     │                │          │        │                   │                                  │ prefix as...                                                 │
│                     │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-45283                   │
│                     ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                     │ CVE-2023-45288 │          │        │                   │ 1.21.9, 1.22.2                   │ golang: net/http, x/net/http2: unlimited number of           │
│                     │                │          │        │                   │                                  │ CONTINUATION frames causes DoS                               │
│                     │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-45288                   │
│                     ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                     │ CVE-2024-34156 │          │        │                   │ 1.22.7, 1.23.1                   │ encoding/gob: golang: Calling Decoder.Decode on a message    │
│                     │                │          │        │                   │                                  │ which contains deeply nested structures...                   │
│                     │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-34156                   │
└─────────────────────┴────────────────┴──────────┴────────┴───────────────────┴──────────────────────────────────┴──────────────────────────────────────────────────────────────┘

usr/bin/aws-iam-authenticator (gobinary)
========================================
Total: 15 (HIGH: 12, CRITICAL: 3)

┌──────────────────┬────────────────┬──────────┬────────┬───────────────────┬──────────────────────────────────┬──────────────────────────────────────────────────────────────┐
│     Library      │ Vulnerability  │ Severity │ Status │ Installed Version │          Fixed Version           │                            Title                             │
├──────────────────┼────────────────┼──────────┼────────┼───────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ golang.org/x/net │ CVE-2023-39325 │ HIGH     │ fixed  │ v0.7.0            │ 0.17.0                           │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                  │                │          │        │                   │                                  │ excessive work (CVE-2023-44487)                              │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                  ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2024-45338 │          │        │                   │ 0.33.0                           │ golang.org/x/net/html: Non-linear parsing of                 │
│                  │                │          │        │                   │                                  │ case-insensitive content in golang.org/x/net/html            │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-45338                   │
├──────────────────┼────────────────┼──────────┤        ├───────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ stdlib           │ CVE-2023-24538 │ CRITICAL │        │ v1.20.1           │ 1.19.8, 1.20.3                   │ golang: html/template: backticks not treated as string       │
│                  │                │          │        │                   │                                  │ delimiters                                                   │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-24538                   │
│                  ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-24540 │          │        │                   │ 1.19.9, 1.20.4                   │ golang: html/template: improper handling of JavaScript       │
│                  │                │          │        │                   │                                  │ whitespace                                                   │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-24540                   │
│                  ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2024-24790 │          │        │                   │ 1.21.11, 1.22.4                  │ golang: net/netip: Unexpected behavior from Is methods for   │
│                  │                │          │        │                   │                                  │ IPv4-mapped IPv6 addresses                                   │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-24790                   │
│                  ├────────────────┼──────────┤        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-24534 │ HIGH     │        │                   │ 1.19.8, 1.20.3                   │ golang: net/http, net/textproto: denial of service from      │
│                  │                │          │        │                   │                                  │ excessive memory allocation                                  │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-24534                   │
│                  ├────────────────┤          │        │                   │                                  ├──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-24536 │          │        │                   │                                  │ golang: net/http, net/textproto, mime/multipart: denial of   │
│                  │                │          │        │                   │                                  │ service from excessive resource consumption                  │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-24536                   │
│                  ├────────────────┤          │        │                   │                                  ├──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-24537 │          │        │                   │                                  │ golang: go/parser: Infinite loop in parsing                  │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-24537                   │
│                  ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-24539 │          │        │                   │ 1.19.9, 1.20.4                   │ golang: html/template: improper sanitization of CSS values   │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-24539                   │
│                  ├────────────────┤          │        │                   │                                  ├──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-29400 │          │        │                   │                                  │ golang: html/template: improper handling of empty HTML       │
│                  │                │          │        │                   │                                  │ attributes                                                   │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-29400                   │
│                  ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-29403 │          │        │                   │ 1.19.10, 1.20.5                  │ golang: runtime: unexpected behavior of setuid/setgid        │
│                  │                │          │        │                   │                                  │ binaries                                                     │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-29403                   │
│                  ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-39325 │          │        │                   │ 1.20.10, 1.21.3                  │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                  │                │          │        │                   │                                  │ excessive work (CVE-2023-44487)                              │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                  ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-45283 │          │        │                   │ 1.20.11, 1.21.4, 1.20.12, 1.21.5 │ The filepath package does not recognize paths with a \??\    │
│                  │                │          │        │                   │                                  │ prefix as...                                                 │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-45283                   │
│                  ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2023-45288 │          │        │                   │ 1.21.9, 1.22.2                   │ golang: net/http, x/net/http2: unlimited number of           │
│                  │                │          │        │                   │                                  │ CONTINUATION frames causes DoS                               │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-45288                   │
│                  ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                  │ CVE-2024-34156 │          │        │                   │ 1.22.7, 1.23.1                   │ encoding/gob: golang: Calling Decoder.Decode on a message    │
│                  │                │          │        │                   │                                  │ which contains deeply nested structures...                   │
│                  │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-34156                   │
└──────────────────┴────────────────┴──────────┴────────┴───────────────────┴──────────────────────────────────┴──────────────────────────────────────────────────────────────┘

usr/bin/eksctl (gobinary)
=========================
Total: 12 (HIGH: 9, CRITICAL: 3)

┌──────────────────────────┬─────────────────────┬──────────┬────────┬────────────────────────┬──────────────────────────────────┬──────────────────────────────────────────────────────────────┐
│         Library          │    Vulnerability    │ Severity │ Status │   Installed Version    │          Fixed Version           │                            Title                             │
├──────────────────────────┼─────────────────────┼──────────┼────────┼────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ github.com/docker/docker │ CVE-2024-41110      │ CRITICAL │ fixed  │ v20.10.24+incompatible │ 23.0.15, 26.1.5, 27.1.1, 25.0.6  │ moby: Authz zero length regression                           │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2024-41110                   │
├──────────────────────────┼─────────────────────┤          │        ├────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ golang.org/x/crypto      │ CVE-2024-45337      │          │        │ v0.13.0                │ 0.31.0                           │ golang.org/x/crypto/ssh: Misuse of                           │
│                          │                     │          │        │                        │                                  │ ServerConfig.PublicKeyCallback may cause authorization       │
│                          │                     │          │        │                        │                                  │ bypass in golang.org/x/crypto                                │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2024-45337                   │
├──────────────────────────┼─────────────────────┼──────────┤        ├────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ golang.org/x/net         │ CVE-2023-39325      │ HIGH     │        │ v0.15.0                │ 0.17.0                           │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                          │                     │          │        │                        │                                  │ excessive work (CVE-2023-44487)                              │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                          ├─────────────────────┤          │        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                          │ CVE-2024-45338      │          │        │                        │ 0.33.0                           │ golang.org/x/net/html: Non-linear parsing of                 │
│                          │                     │          │        │                        │                                  │ case-insensitive content in golang.org/x/net/html            │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2024-45338                   │
├──────────────────────────┼─────────────────────┤          │        ├────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ google.golang.org/grpc   │ GHSA-m425-mq94-257g │          │        │ v1.55.0                │ 1.56.3, 1.57.1, 1.58.3           │ gRPC-Go HTTP/2 Rapid Reset vulnerability                     │
│                          │                     │          │        │                        │                                  │ https://github.com/advisories/GHSA-m425-mq94-257g            │
├──────────────────────────┼─────────────────────┤          │        ├────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ helm.sh/helm/v3          │ CVE-2024-26147      │          │        │ v3.11.2                │ 3.14.2                           │ helm: Missing YAML Content Leads To Panic                    │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2024-26147                   │
├──────────────────────────┼─────────────────────┤          │        ├────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ k8s.io/kops              │ CVE-2023-1943       │          │        │ v1.25.2                │ 1.25.4, 1.26.2                   │ kubernetes/kops: Privilege Escalation in kOps using GCE/GCP  │
│                          │                     │          │        │                        │                                  │ Provider in Gossip Mode                                      │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-1943                    │
├──────────────────────────┼─────────────────────┼──────────┤        ├────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ stdlib                   │ CVE-2024-24790      │ CRITICAL │        │ v1.20.8                │ 1.21.11, 1.22.4                  │ golang: net/netip: Unexpected behavior from Is methods for   │
│                          │                     │          │        │                        │                                  │ IPv4-mapped IPv6 addresses                                   │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2024-24790                   │
│                          ├─────────────────────┼──────────┤        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                          │ CVE-2023-39325      │ HIGH     │        │                        │ 1.20.10, 1.21.3                  │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                          │                     │          │        │                        │                                  │ excessive work (CVE-2023-44487)                              │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                          ├─────────────────────┤          │        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                          │ CVE-2023-45283      │          │        │                        │ 1.20.11, 1.21.4, 1.20.12, 1.21.5 │ The filepath package does not recognize paths with a \??\    │
│                          │                     │          │        │                        │                                  │ prefix as...                                                 │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-45283                   │
│                          ├─────────────────────┤          │        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                          │ CVE-2023-45288      │          │        │                        │ 1.21.9, 1.22.2                   │ golang: net/http, x/net/http2: unlimited number of           │
│                          │                     │          │        │                        │                                  │ CONTINUATION frames causes DoS                               │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2023-45288                   │
│                          ├─────────────────────┤          │        │                        ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                          │ CVE-2024-34156      │          │        │                        │ 1.22.7, 1.23.1                   │ encoding/gob: golang: Calling Decoder.Decode on a message    │
│                          │                     │          │        │                        │                                  │ which contains deeply nested structures...                   │
│                          │                     │          │        │                        │                                  │ https://avd.aquasec.com/nvd/cve-2024-34156                   │
└──────────────────────────┴─────────────────────┴──────────┴────────┴────────────────────────┴──────────────────────────────────┴──────────────────────────────────────────────────────────────┘

usr/bin/helm (gobinary)
=======================
Total: 10 (HIGH: 7, CRITICAL: 3)

┌──────────────────────────┬─────────────────────┬──────────┬────────┬──────────────────────┬──────────────────────────────────┬──────────────────────────────────────────────────────────────┐
│         Library          │    Vulnerability    │ Severity │ Status │  Installed Version   │          Fixed Version           │                            Title                             │
├──────────────────────────┼─────────────────────┼──────────┼────────┼──────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ github.com/docker/docker │ CVE-2024-41110      │ CRITICAL │ fixed  │ v23.0.3+incompatible │ 23.0.15, 26.1.5, 27.1.1, 25.0.6  │ moby: Authz zero length regression                           │
│                          │                     │          │        │                      │                                  │ https://avd.aquasec.com/nvd/cve-2024-41110                   │
├──────────────────────────┼─────────────────────┤          │        ├──────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ golang.org/x/crypto      │ CVE-2024-45337      │          │        │ v0.11.0              │ 0.31.0                           │ golang.org/x/crypto/ssh: Misuse of                           │
│                          │                     │          │        │                      │                                  │ ServerConfig.PublicKeyCallback may cause authorization       │
│                          │                     │          │        │                      │                                  │ bypass in golang.org/x/crypto                                │
│                          │                     │          │        │                      │                                  │ https://avd.aquasec.com/nvd/cve-2024-45337                   │
├──────────────────────────┼─────────────────────┼──────────┤        ├──────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ golang.org/x/net         │ CVE-2023-39325      │ HIGH     │        │ v0.13.0              │ 0.17.0                           │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                          │                     │          │        │                      │                                  │ excessive work (CVE-2023-44487)                              │
│                          │                     │          │        │                      │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                          ├─────────────────────┤          │        │                      ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                          │ CVE-2024-45338      │          │        │                      │ 0.33.0                           │ golang.org/x/net/html: Non-linear parsing of                 │
│                          │                     │          │        │                      │                                  │ case-insensitive content in golang.org/x/net/html            │
│                          │                     │          │        │                      │                                  │ https://avd.aquasec.com/nvd/cve-2024-45338                   │
├──────────────────────────┼─────────────────────┤          │        ├──────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ google.golang.org/grpc   │ GHSA-m425-mq94-257g │          │        │ v1.54.0              │ 1.56.3, 1.57.1, 1.58.3           │ gRPC-Go HTTP/2 Rapid Reset vulnerability                     │
│                          │                     │          │        │                      │                                  │ https://github.com/advisories/GHSA-m425-mq94-257g            │
├──────────────────────────┼─────────────────────┼──────────┤        ├──────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ stdlib                   │ CVE-2024-24790      │ CRITICAL │        │ v1.20.8              │ 1.21.11, 1.22.4                  │ golang: net/netip: Unexpected behavior from Is methods for   │
│                          │                     │          │        │                      │                                  │ IPv4-mapped IPv6 addresses                                   │
│                          │                     │          │        │                      │                                  │ https://avd.aquasec.com/nvd/cve-2024-24790                   │
│                          ├─────────────────────┼──────────┤        │                      ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                          │ CVE-2023-39325      │ HIGH     │        │                      │ 1.20.10, 1.21.3                  │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                          │                     │          │        │                      │                                  │ excessive work (CVE-2023-44487)                              │
│                          │                     │          │        │                      │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                          ├─────────────────────┤          │        │                      ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                          │ CVE-2023-45283      │          │        │                      │ 1.20.11, 1.21.4, 1.20.12, 1.21.5 │ The filepath package does not recognize paths with a \??\    │
│                          │                     │          │        │                      │                                  │ prefix as...                                                 │
│                          │                     │          │        │                      │                                  │ https://avd.aquasec.com/nvd/cve-2023-45283                   │
│                          ├─────────────────────┤          │        │                      ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                          │ CVE-2023-45288      │          │        │                      │ 1.21.9, 1.22.2                   │ golang: net/http, x/net/http2: unlimited number of           │
│                          │                     │          │        │                      │                                  │ CONTINUATION frames causes DoS                               │
│                          │                     │          │        │                      │                                  │ https://avd.aquasec.com/nvd/cve-2023-45288                   │
│                          ├─────────────────────┤          │        │                      ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                          │ CVE-2024-34156      │          │        │                      │ 1.22.7, 1.23.1                   │ encoding/gob: golang: Calling Decoder.Decode on a message    │
│                          │                     │          │        │                      │                                  │ which contains deeply nested structures...                   │
│                          │                     │          │        │                      │                                  │ https://avd.aquasec.com/nvd/cve-2024-34156                   │
└──────────────────────────┴─────────────────────┴──────────┴────────┴──────────────────────┴──────────────────────────────────┴──────────────────────────────────────────────────────────────┘

usr/bin/kubectl (gobinary)
==========================
Total: 8 (HIGH: 7, CRITICAL: 1)

┌────────────────────────────────┬────────────────┬──────────┬────────┬─────────────────────┬──────────────────────────────────┬──────────────────────────────────────────────────────────────┐
│            Library             │ Vulnerability  │ Severity │ Status │  Installed Version  │          Fixed Version           │                            Title                             │
├────────────────────────────────┼────────────────┼──────────┼────────┼─────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ github.com/docker/distribution │ CVE-2023-2253  │ HIGH     │ fixed  │ v2.8.1+incompatible │ 2.8.2-beta.1                     │ distribution/distribution: DoS from malicious API request    │
│                                │                │          │        │                     │                                  │ https://avd.aquasec.com/nvd/cve-2023-2253                    │
├────────────────────────────────┼────────────────┤          │        ├─────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ golang.org/x/net               │ CVE-2023-39325 │          │        │ v0.8.0              │ 0.17.0                           │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                                │                │          │        │                     │                                  │ excessive work (CVE-2023-44487)                              │
│                                │                │          │        │                     │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                                ├────────────────┤          │        │                     ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                │ CVE-2024-45338 │          │        │                     │ 0.33.0                           │ golang.org/x/net/html: Non-linear parsing of                 │
│                                │                │          │        │                     │                                  │ case-insensitive content in golang.org/x/net/html            │
│                                │                │          │        │                     │                                  │ https://avd.aquasec.com/nvd/cve-2024-45338                   │
├────────────────────────────────┼────────────────┼──────────┤        ├─────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ stdlib                         │ CVE-2024-24790 │ CRITICAL │        │ v1.20.8             │ 1.21.11, 1.22.4                  │ golang: net/netip: Unexpected behavior from Is methods for   │
│                                │                │          │        │                     │                                  │ IPv4-mapped IPv6 addresses                                   │
│                                │                │          │        │                     │                                  │ https://avd.aquasec.com/nvd/cve-2024-24790                   │
│                                ├────────────────┼──────────┤        │                     ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                │ CVE-2023-39325 │ HIGH     │        │                     │ 1.20.10, 1.21.3                  │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                                │                │          │        │                     │                                  │ excessive work (CVE-2023-44487)                              │
│                                │                │          │        │                     │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                                ├────────────────┤          │        │                     ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                │ CVE-2023-45283 │          │        │                     │ 1.20.11, 1.21.4, 1.20.12, 1.21.5 │ The filepath package does not recognize paths with a \??\    │
│                                │                │          │        │                     │                                  │ prefix as...                                                 │
│                                │                │          │        │                     │                                  │ https://avd.aquasec.com/nvd/cve-2023-45283                   │
│                                ├────────────────┤          │        │                     ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                │ CVE-2023-45288 │          │        │                     │ 1.21.9, 1.22.2                   │ golang: net/http, x/net/http2: unlimited number of           │
│                                │                │          │        │                     │                                  │ CONTINUATION frames causes DoS                               │
│                                │                │          │        │                     │                                  │ https://avd.aquasec.com/nvd/cve-2023-45288                   │
│                                ├────────────────┤          │        │                     ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                │ CVE-2024-34156 │          │        │                     │ 1.22.7, 1.23.1                   │ encoding/gob: golang: Calling Decoder.Decode on a message    │
│                                │                │          │        │                     │                                  │ which contains deeply nested structures...                   │
│                                │                │          │        │                     │                                  │ https://avd.aquasec.com/nvd/cve-2024-34156                   │
└────────────────────────────────┴────────────────┴──────────┴────────┴─────────────────────┴──────────────────────────────────┴──────────────────────────────────────────────────────────────┘

usr/bin/kubeseal (gobinary)
===========================
Total: 8 (HIGH: 6, CRITICAL: 2)

┌─────────────────────┬────────────────┬──────────┬────────┬───────────────────┬──────────────────────────────────┬──────────────────────────────────────────────────────────────┐
│       Library       │ Vulnerability  │ Severity │ Status │ Installed Version │          Fixed Version           │                            Title                             │
├─────────────────────┼────────────────┼──────────┼────────┼───────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ golang.org/x/crypto │ CVE-2024-45337 │ CRITICAL │ fixed  │ v0.13.0           │ 0.31.0                           │ golang.org/x/crypto/ssh: Misuse of                           │
│                     │                │          │        │                   │                                  │ ServerConfig.PublicKeyCallback may cause authorization       │
│                     │                │          │        │                   │                                  │ bypass in golang.org/x/crypto                                │
│                     │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-45337                   │
├─────────────────────┼────────────────┼──────────┤        ├───────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ golang.org/x/net    │ CVE-2023-39325 │ HIGH     │        │ v0.14.0           │ 0.17.0                           │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                     │                │          │        │                   │                                  │ excessive work (CVE-2023-44487)                              │
│                     │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                     ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                     │ CVE-2024-45338 │          │        │                   │ 0.33.0                           │ golang.org/x/net/html: Non-linear parsing of                 │
│                     │                │          │        │                   │                                  │ case-insensitive content in golang.org/x/net/html            │
│                     │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-45338                   │
├─────────────────────┼────────────────┼──────────┤        ├───────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ stdlib              │ CVE-2024-24790 │ CRITICAL │        │ v1.21.1           │ 1.21.11, 1.22.4                  │ golang: net/netip: Unexpected behavior from Is methods for   │
│                     │                │          │        │                   │                                  │ IPv4-mapped IPv6 addresses                                   │
│                     │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-24790                   │
│                     ├────────────────┼──────────┤        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                     │ CVE-2023-39325 │ HIGH     │        │                   │ 1.20.10, 1.21.3                  │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                     │                │          │        │                   │                                  │ excessive work (CVE-2023-44487)                              │
│                     │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                     ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                     │ CVE-2023-45283 │          │        │                   │ 1.20.11, 1.21.4, 1.20.12, 1.21.5 │ The filepath package does not recognize paths with a \??\    │
│                     │                │          │        │                   │                                  │ prefix as...                                                 │
│                     │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-45283                   │
│                     ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                     │ CVE-2023-45288 │          │        │                   │ 1.21.9, 1.22.2                   │ golang: net/http, x/net/http2: unlimited number of           │
│                     │                │          │        │                   │                                  │ CONTINUATION frames causes DoS                               │
│                     │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-45288                   │
│                     ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                     │ CVE-2024-34156 │          │        │                   │ 1.22.7, 1.23.1                   │ encoding/gob: golang: Calling Decoder.Decode on a message    │
│                     │                │          │        │                   │                                  │ which contains deeply nested structures...                   │
│                     │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-34156                   │
└─────────────────────┴────────────────┴──────────┴────────┴───────────────────┴──────────────────────────────────┴──────────────────────────────────────────────────────────────┘

usr/bin/kustomize (gobinary)
============================
Total: 5 (HIGH: 4, CRITICAL: 1)

┌─────────┬────────────────┬──────────┬────────┬───────────────────┬──────────────────────────────────┬──────────────────────────────────────────────────────────────┐
│ Library │ Vulnerability  │ Severity │ Status │ Installed Version │          Fixed Version           │                            Title                             │
├─────────┼────────────────┼──────────┼────────┼───────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ stdlib  │ CVE-2024-24790 │ CRITICAL │ fixed  │ v1.20.6           │ 1.21.11, 1.22.4                  │ golang: net/netip: Unexpected behavior from Is methods for   │
│         │                │          │        │                   │                                  │ IPv4-mapped IPv6 addresses                                   │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-24790                   │
│         ├────────────────┼──────────┤        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2023-39325 │ HIGH     │        │                   │ 1.20.10, 1.21.3                  │ golang: net/http, x/net/http2: rapid stream resets can cause │
│         │                │          │        │                   │                                  │ excessive work (CVE-2023-44487)                              │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2023-45283 │          │        │                   │ 1.20.11, 1.21.4, 1.20.12, 1.21.5 │ The filepath package does not recognize paths with a \??\    │
│         │                │          │        │                   │                                  │ prefix as...                                                 │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-45283                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2023-45288 │          │        │                   │ 1.21.9, 1.22.2                   │ golang: net/http, x/net/http2: unlimited number of           │
│         │                │          │        │                   │                                  │ CONTINUATION frames causes DoS                               │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-45288                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2024-34156 │          │        │                   │ 1.22.7, 1.23.1                   │ encoding/gob: golang: Calling Decoder.Decode on a message    │
│         │                │          │        │                   │                                  │ which contains deeply nested structures...                   │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-34156                   │
└─────────┴────────────────┴──────────┴────────┴───────────────────┴──────────────────────────────────┴──────────────────────────────────────────────────────────────┘
