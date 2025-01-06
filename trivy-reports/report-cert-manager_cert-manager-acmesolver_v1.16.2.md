
<h3>Target <code>quay.io/jetstack/cert-manager-acmesolver:v1.16.2 (debian 12.8)</code></h3>
<h4>No Vulnerabilities found</h4>
<h4>No Misconfigurations found</h4>
<h3>Target <code>app/cmd/acmesolver/acmesolver</code></h3>
<h4>Vulnerabilities (1)</h4>
<table>
    <tr>
        <th>Package</th>
        <th>ID</th>
        <th>Severity</th>
        <th>Installed Version</th>
        <th>Fixed Version</th>
    </tr>
    <tr>
        <td><code>golang.org/x/net</code></td>
        <td>CVE-2024-45338</td>
        <td>HIGH</td>
        <td>v0.29.0</td>
        <td>0.33.0</td>
    </tr>
</table>
<h4>No Misconfigurations found</h4>
ariable.


quay.io/jetstack/cert-manager-acmesolver:v1.16.2 (debian 12.8)
==============================================================
Total: 0 (HIGH: 0, CRITICAL: 0)


app/cmd/acmesolver/acmesolver (gobinary)
========================================
Total: 1 (HIGH: 1, CRITICAL: 0)

┌──────────────────┬────────────────┬──────────┬────────┬───────────────────┬───────────────┬───────────────────────────────────────────────────┐
│     Library      │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version │                       Title                       │
├──────────────────┼────────────────┼──────────┼────────┼───────────────────┼───────────────┼───────────────────────────────────────────────────┤
│ golang.org/x/net │ CVE-2024-45338 │ HIGH     │ fixed  │ v0.29.0           │ 0.33.0        │ golang.org/x/net/html: Non-linear parsing of      │
│                  │                │          │        │                   │               │ case-insensitive content in golang.org/x/net/html │
│                  │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-45338        │
└──────────────────┴────────────────┴──────────┴────────┴───────────────────┴───────────────┴───────────────────────────────────────────────────┘
