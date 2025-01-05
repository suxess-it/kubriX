
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


ghcr.io/grafana/xk6-client-tracing:v0.0.2 (alpine 3.17.0)
=========================================================
Total: 18 (HIGH: 18, CRITICAL: 0)

┌────────────┬───────────────┬──────────┬────────┬───────────────────┬───────────────┬─────────────────────────────────────────────────────────────┐
│  Library   │ Vulnerability │ Severity │ Status │ Installed Version │ Fixed Version │                            Title                            │
├────────────┼───────────────┼──────────┼────────┼───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ libcrypto3 │ CVE-2022-3996 │ HIGH     │ fixed  │ 3.0.7-r0          │ 3.0.7-r2      │ openssl: double locking leads to denial of service          │
│            │               │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2022-3996                   │
│            ├───────────────┤          │        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│            │ CVE-2022-4450 │          │        │                   │ 3.0.8-r0      │ openssl: double free after calling PEM_read_bio_ex          │
│            │               │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2022-4450                   │
│            ├───────────────┤          │        │                   │               ├─────────────────────────────────────────────────────────────┤
│            │ CVE-2023-0215 │          │        │                   │               │ openssl: use-after-free following BIO_new_NDEF              │
│            │               │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-0215                   │
│            ├───────────────┤          │        │                   │               ├─────────────────────────────────────────────────────────────┤
│            │ CVE-2023-0216 │          │        │                   │               │ openssl: invalid pointer dereference in d2i_PKCS7 functions │
│            │               │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-0216                   │
│            ├───────────────┤          │        │                   │               ├─────────────────────────────────────────────────────────────┤
│            │ CVE-2023-0217 │          │        │                   │               │ openssl: NULL dereference validating DSA public key         │
│            │               │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-0217                   │
│            ├───────────────┤          │        │                   │               ├─────────────────────────────────────────────────────────────┤
│            │ CVE-2023-0286 │          │        │                   │               │ openssl: X.400 address type confusion in X.509 GeneralName  │
│            │               │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-0286                   │
│            ├───────────────┤          │        │                   │               ├─────────────────────────────────────────────────────────────┤
│            │ CVE-2023-0401 │          │        │                   │               │ openssl: NULL dereference during PKCS7 data verification    │
│            │               │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-0401                   │
│            ├───────────────┤          │        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│            │ CVE-2023-0464 │          │        │                   │ 3.0.8-r1      │ openssl: Denial of service by excessive resource usage in   │
│            │               │          │        │                   │               │ verifying X509 policy...                                    │
│            │               │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-0464                   │
│            ├───────────────┤          │        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│            │ CVE-2023-5363 │          │        │                   │ 3.0.12-r0     │ openssl: Incorrect cipher key and IV length processing      │
│            │               │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-5363                   │
├────────────┼───────────────┤          │        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│ libssl3    │ CVE-2022-3996 │          │        │                   │ 3.0.7-r2      │ openssl: double locking leads to denial of service          │
│            │               │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2022-3996                   │
│            ├───────────────┤          │        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│            │ CVE-2022-4450 │          │        │                   │ 3.0.8-r0      │ openssl: double free after calling PEM_read_bio_ex          │
│            │               │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2022-4450                   │
│            ├───────────────┤          │        │                   │               ├─────────────────────────────────────────────────────────────┤
│            │ CVE-2023-0215 │          │        │                   │               │ openssl: use-after-free following BIO_new_NDEF              │
│            │               │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-0215                   │
│            ├───────────────┤          │        │                   │               ├─────────────────────────────────────────────────────────────┤
│            │ CVE-2023-0216 │          │        │                   │               │ openssl: invalid pointer dereference in d2i_PKCS7 functions │
│            │               │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-0216                   │
│            ├───────────────┤          │        │                   │               ├─────────────────────────────────────────────────────────────┤
│            │ CVE-2023-0217 │          │        │                   │               │ openssl: NULL dereference validating DSA public key         │
│            │               │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-0217                   │
│            ├───────────────┤          │        │                   │               ├─────────────────────────────────────────────────────────────┤
│            │ CVE-2023-0286 │          │        │                   │               │ openssl: X.400 address type confusion in X.509 GeneralName  │
│            │               │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-0286                   │
│            ├───────────────┤          │        │                   │               ├─────────────────────────────────────────────────────────────┤
│            │ CVE-2023-0401 │          │        │                   │               │ openssl: NULL dereference during PKCS7 data verification    │
│            │               │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-0401                   │
│            ├───────────────┤          │        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│            │ CVE-2023-0464 │          │        │                   │ 3.0.8-r1      │ openssl: Denial of service by excessive resource usage in   │
│            │               │          │        │                   │               │ verifying X509 policy...                                    │
│            │               │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-0464                   │
│            ├───────────────┤          │        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│            │ CVE-2023-5363 │          │        │                   │ 3.0.12-r0     │ openssl: Incorrect cipher key and IV length processing      │
│            │               │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-5363                   │
└────────────┴───────────────┴──────────┴────────┴───────────────────┴───────────────┴─────────────────────────────────────────────────────────────┘

k6-tracing (gobinary)
=====================
Total: 28 (HIGH: 24, CRITICAL: 4)

┌──────────────────────────────────────────────────────────────┬─────────────────────┬──────────┬────────┬────────────────────────────────────┬─────────────────────────────────────┬──────────────────────────────────────────────────────────────┐
│                           Library                            │    Vulnerability    │ Severity │ Status │         Installed Version          │            Fixed Version            │                            Title                             │
├──────────────────────────────────────────────────────────────┼─────────────────────┼──────────┼────────┼────────────────────────────────────┼─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ github.com/mostynb/go-grpc-compression                       │ GHSA-87m9-rv8p-rgmg │ HIGH     │ fixed  │ v1.1.17                            │ 1.2.3                               │ go-grpc-compression has a zstd decompression bombing         │
│                                                              │                     │          │        │                                    │                                     │ vulnerability                                                │
│                                                              │                     │          │        │                                    │                                     │ https://github.com/advisories/GHSA-87m9-rv8p-rgmg            │
├──────────────────────────────────────────────────────────────┼─────────────────────┤          │        ├────────────────────────────────────┼─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ go.opentelemetry.io/contrib/instrumentation/google.golang.o- │ CVE-2023-47108      │          │        │ v0.36.1                            │ 0.46.0                              │ opentelemetry-go-contrib: DoS vulnerability in otelgrpc due  │
│ rg/grpc/otelgrpc                                             │                     │          │        │                                    │                                     │ to unbound cardinality metrics                               │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2023-47108                   │
├──────────────────────────────────────────────────────────────┼─────────────────────┼──────────┤        ├────────────────────────────────────┼─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ golang.org/x/crypto                                          │ CVE-2024-45337      │ CRITICAL │        │ v0.0.0-20220622213112-05595931fe9d │ 0.31.0                              │ golang.org/x/crypto/ssh: Misuse of                           │
│                                                              │                     │          │        │                                    │                                     │ ServerConfig.PublicKeyCallback may cause authorization       │
│                                                              │                     │          │        │                                    │                                     │ bypass in golang.org/x/crypto                                │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2024-45337                   │
├──────────────────────────────────────────────────────────────┼─────────────────────┼──────────┤        ├────────────────────────────────────┼─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ golang.org/x/net                                             │ CVE-2022-41721      │ HIGH     │        │ v0.0.0-20220926192436-02166a98028e │ 0.1.1-0.20221104162952-702349b0e862 │ x/net/http2/h2c: request smuggling                           │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2022-41721                   │
│                                                              ├─────────────────────┤          │        │                                    ├─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2022-41723      │          │        │                                    │ 0.7.0                               │ golang.org/x/net/http2: avoid quadratic complexity in HPACK  │
│                                                              │                     │          │        │                                    │                                     │ decoding                                                     │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2022-41723                   │
│                                                              ├─────────────────────┤          │        │                                    ├─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2023-39325      │          │        │                                    │ 0.17.0                              │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                                                              │                     │          │        │                                    │                                     │ excessive work (CVE-2023-44487)                              │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                                                              ├─────────────────────┤          │        │                                    ├─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2024-45338      │          │        │                                    │ 0.33.0                              │ golang.org/x/net/html: Non-linear parsing of                 │
│                                                              │                     │          │        │                                    │                                     │ case-insensitive content in golang.org/x/net/html            │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2024-45338                   │
├──────────────────────────────────────────────────────────────┼─────────────────────┤          │        ├────────────────────────────────────┼─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ golang.org/x/text                                            │ CVE-2022-32149      │          │        │ v0.3.7                             │ 0.3.8                               │ golang: golang.org/x/text/language: ParseAcceptLanguage      │
│                                                              │                     │          │        │                                    │                                     │ takes a long time to parse complex tags                      │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2022-32149                   │
├──────────────────────────────────────────────────────────────┼─────────────────────┤          │        ├────────────────────────────────────┼─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ google.golang.org/grpc                                       │ GHSA-m425-mq94-257g │          │        │ v1.50.0                            │ 1.56.3, 1.57.1, 1.58.3              │ gRPC-Go HTTP/2 Rapid Reset vulnerability                     │
│                                                              │                     │          │        │                                    │                                     │ https://github.com/advisories/GHSA-m425-mq94-257g            │
├──────────────────────────────────────────────────────────────┼─────────────────────┼──────────┤        ├────────────────────────────────────┼─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ stdlib                                                       │ CVE-2023-24538      │ CRITICAL │        │ v1.19.3                            │ 1.19.8, 1.20.3                      │ golang: html/template: backticks not treated as string       │
│                                                              │                     │          │        │                                    │                                     │ delimiters                                                   │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2023-24538                   │
│                                                              ├─────────────────────┤          │        │                                    ├─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2023-24540      │          │        │                                    │ 1.19.9, 1.20.4                      │ golang: html/template: improper handling of JavaScript       │
│                                                              │                     │          │        │                                    │                                     │ whitespace                                                   │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2023-24540                   │
│                                                              ├─────────────────────┤          │        │                                    ├─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2024-24790      │          │        │                                    │ 1.21.11, 1.22.4                     │ golang: net/netip: Unexpected behavior from Is methods for   │
│                                                              │                     │          │        │                                    │                                     │ IPv4-mapped IPv6 addresses                                   │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2024-24790                   │
│                                                              ├─────────────────────┼──────────┤        │                                    ├─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2022-41720      │ HIGH     │        │                                    │ 1.18.9, 1.19.4                      │ golang: os, net/http: avoid escapes from os.DirFS and        │
│                                                              │                     │          │        │                                    │                                     │ http.Dir on Windows                                          │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2022-41720                   │
│                                                              ├─────────────────────┤          │        │                                    ├─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2022-41722      │          │        │                                    │ 1.19.6, 1.20.1                      │ golang: path/filepath: path-filepath filepath.Clean path     │
│                                                              │                     │          │        │                                    │                                     │ traversal                                                    │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2022-41722                   │
│                                                              ├─────────────────────┤          │        │                                    │                                     ├──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2022-41723      │          │        │                                    │                                     │ golang.org/x/net/http2: avoid quadratic complexity in HPACK  │
│                                                              │                     │          │        │                                    │                                     │ decoding                                                     │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2022-41723                   │
│                                                              ├─────────────────────┤          │        │                                    │                                     ├──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2022-41724      │          │        │                                    │                                     │ golang: crypto/tls: large handshake records may cause panics │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2022-41724                   │
│                                                              ├─────────────────────┤          │        │                                    │                                     ├──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2022-41725      │          │        │                                    │                                     │ golang: net/http, mime/multipart: denial of service from     │
│                                                              │                     │          │        │                                    │                                     │ excessive resource consumption                               │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2022-41725                   │
│                                                              ├─────────────────────┤          │        │                                    ├─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2023-24534      │          │        │                                    │ 1.19.8, 1.20.3                      │ golang: net/http, net/textproto: denial of service from      │
│                                                              │                     │          │        │                                    │                                     │ excessive memory allocation                                  │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2023-24534                   │
│                                                              ├─────────────────────┤          │        │                                    │                                     ├──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2023-24536      │          │        │                                    │                                     │ golang: net/http, net/textproto, mime/multipart: denial of   │
│                                                              │                     │          │        │                                    │                                     │ service from excessive resource consumption                  │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2023-24536                   │
│                                                              ├─────────────────────┤          │        │                                    │                                     ├──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2023-24537      │          │        │                                    │                                     │ golang: go/parser: Infinite loop in parsing                  │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2023-24537                   │
│                                                              ├─────────────────────┤          │        │                                    ├─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2023-24539      │          │        │                                    │ 1.19.9, 1.20.4                      │ golang: html/template: improper sanitization of CSS values   │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2023-24539                   │
│                                                              ├─────────────────────┤          │        │                                    │                                     ├──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2023-29400      │          │        │                                    │                                     │ golang: html/template: improper handling of empty HTML       │
│                                                              │                     │          │        │                                    │                                     │ attributes                                                   │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2023-29400                   │
│                                                              ├─────────────────────┤          │        │                                    ├─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2023-29403      │          │        │                                    │ 1.19.10, 1.20.5                     │ golang: runtime: unexpected behavior of setuid/setgid        │
│                                                              │                     │          │        │                                    │                                     │ binaries                                                     │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2023-29403                   │
│                                                              ├─────────────────────┤          │        │                                    ├─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2023-39325      │          │        │                                    │ 1.20.10, 1.21.3                     │ golang: net/http, x/net/http2: rapid stream resets can cause │
│                                                              │                     │          │        │                                    │                                     │ excessive work (CVE-2023-44487)                              │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│                                                              ├─────────────────────┤          │        │                                    ├─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2023-45283      │          │        │                                    │ 1.20.11, 1.21.4, 1.20.12, 1.21.5    │ The filepath package does not recognize paths with a \??\    │
│                                                              │                     │          │        │                                    │                                     │ prefix as...                                                 │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2023-45283                   │
│                                                              ├─────────────────────┤          │        │                                    ├─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2023-45287      │          │        │                                    │ 1.20.0                              │ golang: crypto/tls: Timing Side Channel attack in RSA based  │
│                                                              │                     │          │        │                                    │                                     │ TLS key exchanges....                                        │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2023-45287                   │
│                                                              ├─────────────────────┤          │        │                                    ├─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2023-45288      │          │        │                                    │ 1.21.9, 1.22.2                      │ golang: net/http, x/net/http2: unlimited number of           │
│                                                              │                     │          │        │                                    │                                     │ CONTINUATION frames causes DoS                               │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2023-45288                   │
│                                                              ├─────────────────────┤          │        │                                    ├─────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│                                                              │ CVE-2024-34156      │          │        │                                    │ 1.22.7, 1.23.1                      │ encoding/gob: golang: Calling Decoder.Decode on a message    │
│                                                              │                     │          │        │                                    │                                     │ which contains deeply nested structures...                   │
│                                                              │                     │          │        │                                    │                                     │ https://avd.aquasec.com/nvd/cve-2024-34156                   │
└──────────────────────────────────────────────────────────────┴─────────────────────┴──────────┴────────┴────────────────────────────────────┴─────────────────────────────────────┴──────────────────────────────────────────────────────────────┘
