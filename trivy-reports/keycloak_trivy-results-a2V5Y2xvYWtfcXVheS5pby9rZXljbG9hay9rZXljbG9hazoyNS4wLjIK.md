
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


quay.io/keycloak/keycloak:25.0.2 (redhat 9.4)
=============================================
Total: 0 (HIGH: 0, CRITICAL: 0)


Java (jar)
==========
Total: 6 (HIGH: 6, CRITICAL: 0)

┌─────────────────────────────────────────────────────┬────────────────┬──────────┬────────┬───────────────────┬─────────────────────────┬─────────────────────────────────────────────────────────────┐
│                       Library                       │ Vulnerability  │ Severity │ Status │ Installed Version │      Fixed Version      │                            Title                            │
├─────────────────────────────────────────────────────┼────────────────┼──────────┼────────┼───────────────────┼─────────────────────────┼─────────────────────────────────────────────────────────────┤
│ io.quarkus.http:quarkus-http-core                   │ CVE-2024-12397 │ HIGH     │ fixed  │ 5.2.2.Final       │ 5.3.4                   │ io.quarkus.http/quarkus-http-core: Quarkus HTTP Cookie      │
│ (io.quarkus.http.quarkus-http-core-5.2.2.Final.jar) │                │          │        │                   │                         │ Smuggling                                                   │
│                                                     │                │          │        │                   │                         │ https://avd.aquasec.com/nvd/cve-2024-12397                  │
├─────────────────────────────────────────────────────┼────────────────┤          │        ├───────────────────┼─────────────────────────┼─────────────────────────────────────────────────────────────┤
│ org.keycloak:keycloak-core                          │ CVE-2024-10039 │          │        │ 25.0.2            │ 26.0.6                  │ keycloak-core: mTLS passthrough                             │
│ (org.keycloak.keycloak-core-25.0.2.jar)             │                │          │        │                   │                         │ https://avd.aquasec.com/nvd/cve-2024-10039                  │
├─────────────────────────────────────────────────────┼────────────────┤          │        │                   ├─────────────────────────┼─────────────────────────────────────────────────────────────┤
│ org.keycloak:keycloak-quarkus-server                │ CVE-2024-10451 │          │        │                   │ 24.0.9, 26.0.6          │ org.keycloak:keycloak-quarkus-server: Sensitive Data        │
│ (org.keycloak.keycloak-quarkus-server-25.0.2.jar)   │                │          │        │                   │                         │ Exposure in Keycloak Build Process                          │
│                                                     │                │          │        │                   │                         │ https://avd.aquasec.com/nvd/cve-2024-10451                  │
├─────────────────────────────────────────────────────┼────────────────┤          │        │                   ├─────────────────────────┼─────────────────────────────────────────────────────────────┤
│ org.keycloak:keycloak-saml-core                     │ CVE-2024-8698  │          │        │                   │ 22.0.13, 24.0.8, 25.0.6 │ keycloak-saml-core: Improper Verification of SAML Responses │
│ (org.keycloak.keycloak-saml-core-25.0.2.jar)        │                │          │        │                   │                         │ Leading to Privilege Escalation in Keycloak...              │
│                                                     │                │          │        │                   │                         │ https://avd.aquasec.com/nvd/cve-2024-8698                   │
├─────────────────────────────────────────────────────┼────────────────┤          │        │                   ├─────────────────────────┼─────────────────────────────────────────────────────────────┤
│ org.keycloak:keycloak-services                      │ CVE-2024-10270 │          │        │                   │ 24.0.9, 26.0.6          │ org.keycloak:keycloak-services: Keycloak Denial of Service  │
│ (org.keycloak.keycloak-services-25.0.2.jar)         │                │          │        │                   │                         │ https://avd.aquasec.com/nvd/cve-2024-10270                  │
│                                                     ├────────────────┤          │        │                   ├─────────────────────────┼─────────────────────────────────────────────────────────────┤
│                                                     │ CVE-2024-7341  │          │        │                   │ 22.0.12, 24.0.7, 25.0.5 │ wildfly-elytron: org.keycloak/keycloak-services: session    │
│                                                     │                │          │        │                   │                         │ fixation in elytron saml adapters                           │
│                                                     │                │          │        │                   │                         │ https://avd.aquasec.com/nvd/cve-2024-7341                   │
└─────────────────────────────────────────────────────┴────────────────┴──────────┴────────┴───────────────────┴─────────────────────────┴─────────────────────────────────────────────────────────────┘
