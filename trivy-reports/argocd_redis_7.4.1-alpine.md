
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


public.ecr.aws/docker/library/redis:7.4.1-alpine (alpine 3.20.3)
================================================================
Total: 0 (HIGH: 0, CRITICAL: 0)


usr/local/bin/gosu (gobinary)
=============================
Total: 34 (HIGH: 31, CRITICAL: 3)

┌─────────┬────────────────┬──────────┬────────┬───────────────────┬──────────────────────────────────┬──────────────────────────────────────────────────────────────┐
│ Library │ Vulnerability  │ Severity │ Status │ Installed Version │          Fixed Version           │                            Title                             │
├─────────┼────────────────┼──────────┼────────┼───────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ stdlib  │ CVE-2023-24538 │ CRITICAL │ fixed  │ v1.18.2           │ 1.19.8, 1.20.3                   │ golang: html/template: backticks not treated as string       │
│         │                │          │        │                   │                                  │ delimiters                                                   │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-24538                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2023-24540 │          │        │                   │ 1.19.9, 1.20.4                   │ golang: html/template: improper handling of JavaScript       │
│         │                │          │        │                   │                                  │ whitespace                                                   │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-24540                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2024-24790 │          │        │                   │ 1.21.11, 1.22.4                  │ golang: net/netip: Unexpected behavior from Is methods for   │
│         │                │          │        │                   │                                  │ IPv4-mapped IPv6 addresses                                   │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-24790                   │
│         ├────────────────┼──────────┤        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-27664 │ HIGH     │        │                   │ 1.18.6, 1.19.1                   │ golang: net/http: handle server errors after sending GOAWAY  │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-27664                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-28131 │          │        │                   │ 1.17.12, 1.18.4                  │ golang: encoding/xml: stack exhaustion in Decoder.Skip       │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-28131                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-2879  │          │        │                   │ 1.18.7, 1.19.2                   │ golang: archive/tar: unbounded memory consumption when       │
│         │                │          │        │                   │                                  │ reading headers                                              │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-2879                    │
│         ├────────────────┤          │        │                   │                                  ├──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-2880  │          │        │                   │                                  │ golang: net/http/httputil: ReverseProxy should not forward   │
│         │                │          │        │                   │                                  │ unparseable query parameters                                 │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-2880                    │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-29804 │          │        │                   │ 1.17.11, 1.18.3                  │ ELSA-2022-17957: ol8addon security update (IMPORTANT)        │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-29804                   │
│         ├────────────────┤          │        │                   │                                  ├──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-30580 │          │        │                   │                                  │ golang: os/exec: Code injection in Cmd.Start                 │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-30580                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-30630 │          │        │                   │ 1.17.12, 1.18.4                  │ golang: io/fs: stack exhaustion in Glob                      │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-30630                   │
│         ├────────────────┤          │        │                   │                                  ├──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-30631 │          │        │                   │                                  │ golang: compress/gzip: stack exhaustion in Reader.Read       │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-30631                   │
│         ├────────────────┤          │        │                   │                                  ├──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-30632 │          │        │                   │                                  │ golang: path/filepath: stack exhaustion in Glob              │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-30632                   │
│         ├────────────────┤          │        │                   │                                  ├──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-30633 │          │        │                   │                                  │ golang: encoding/xml: stack exhaustion in Unmarshal          │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-30633                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-30634 │          │        │                   │ 1.17.11, 1.18.3                  │ ELSA-2022-17957: ol8addon security update (IMPORTANT)        │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-30634                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-30635 │          │        │                   │ 1.17.12, 1.18.4                  │ golang: encoding/gob: stack exhaustion in Decoder.Decode     │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-30635                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-32189 │          │        │                   │ 1.17.13, 1.18.5                  │ golang: math/big: decoding big.Float and big.Rat types can   │
│         │                │          │        │                   │                                  │ panic if the encoded...                                      │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-32189                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-41715 │          │        │                   │ 1.18.7, 1.19.2                   │ golang: regexp/syntax: limit memory used by parsing regexps  │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-41715                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-41716 │          │        │                   │ 1.18.8, 1.19.3                   │ Due to unsanitized NUL values, attackers may be able to      │
│         │                │          │        │                   │                                  │ maliciously se...                                            │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-41716                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-41720 │          │        │                   │ 1.18.9, 1.19.4                   │ golang: os, net/http: avoid escapes from os.DirFS and        │
│         │                │          │        │                   │                                  │ http.Dir on Windows                                          │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-41720                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-41722 │          │        │                   │ 1.19.6, 1.20.1                   │ golang: path/filepath: path-filepath filepath.Clean path     │
│         │                │          │        │                   │                                  │ traversal                                                    │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-41722                   │
│         ├────────────────┤          │        │                   │                                  ├──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-41723 │          │        │                   │                                  │ golang.org/x/net/http2: avoid quadratic complexity in HPACK  │
│         │                │          │        │                   │                                  │ decoding                                                     │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-41723                   │
│         ├────────────────┤          │        │                   │                                  ├──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-41724 │          │        │                   │                                  │ golang: crypto/tls: large handshake records may cause panics │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-41724                   │
│         ├────────────────┤          │        │                   │                                  ├──────────────────────────────────────────────────────────────┤
│         │ CVE-2022-41725 │          │        │                   │                                  │ golang: net/http, mime/multipart: denial of service from     │
│         │                │          │        │                   │                                  │ excessive resource consumption                               │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2022-41725                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2023-24534 │          │        │                   │ 1.19.8, 1.20.3                   │ golang: net/http, net/textproto: denial of service from      │
│         │                │          │        │                   │                                  │ excessive memory allocation                                  │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-24534                   │
│         ├────────────────┤          │        │                   │                                  ├──────────────────────────────────────────────────────────────┤
│         │ CVE-2023-24536 │          │        │                   │                                  │ golang: net/http, net/textproto, mime/multipart: denial of   │
│         │                │          │        │                   │                                  │ service from excessive resource consumption                  │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-24536                   │
│         ├────────────────┤          │        │                   │                                  ├──────────────────────────────────────────────────────────────┤
│         │ CVE-2023-24537 │          │        │                   │                                  │ golang: go/parser: Infinite loop in parsing                  │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-24537                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2023-24539 │          │        │                   │ 1.19.9, 1.20.4                   │ golang: html/template: improper sanitization of CSS values   │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-24539                   │
│         ├────────────────┤          │        │                   │                                  ├──────────────────────────────────────────────────────────────┤
│         │ CVE-2023-29400 │          │        │                   │                                  │ golang: html/template: improper handling of empty HTML       │
│         │                │          │        │                   │                                  │ attributes                                                   │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-29400                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2023-29403 │          │        │                   │ 1.19.10, 1.20.5                  │ golang: runtime: unexpected behavior of setuid/setgid        │
│         │                │          │        │                   │                                  │ binaries                                                     │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-29403                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2023-39325 │          │        │                   │ 1.20.10, 1.21.3                  │ golang: net/http, x/net/http2: rapid stream resets can cause │
│         │                │          │        │                   │                                  │ excessive work (CVE-2023-44487)                              │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-39325                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2023-45283 │          │        │                   │ 1.20.11, 1.21.4, 1.20.12, 1.21.5 │ The filepath package does not recognize paths with a \??\    │
│         │                │          │        │                   │                                  │ prefix as...                                                 │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-45283                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2023-45287 │          │        │                   │ 1.20.0                           │ golang: crypto/tls: Timing Side Channel attack in RSA based  │
│         │                │          │        │                   │                                  │ TLS key exchanges....                                        │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-45287                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2023-45288 │          │        │                   │ 1.21.9, 1.22.2                   │ golang: net/http, x/net/http2: unlimited number of           │
│         │                │          │        │                   │                                  │ CONTINUATION frames causes DoS                               │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2023-45288                   │
│         ├────────────────┤          │        │                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│         │ CVE-2024-34156 │          │        │                   │ 1.22.7, 1.23.1                   │ encoding/gob: golang: Calling Decoder.Decode on a message    │
│         │                │          │        │                   │                                  │ which contains deeply nested structures...                   │
│         │                │          │        │                   │                                  │ https://avd.aquasec.com/nvd/cve-2024-34156                   │
└─────────┴────────────────┴──────────┴────────┴───────────────────┴──────────────────────────────────┴──────────────────────────────────────────────────────────────┘
