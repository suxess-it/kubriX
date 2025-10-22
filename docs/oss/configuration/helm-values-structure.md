# Konfigurationsstruktur von kubriX

## Herausforderungen einer modularen, vorkonfigurierten aber flexiblen IDP Distribution

kubriX soll nicht nur ein Set an ausgewählten CNCF Projekten sein,
sondern bereits vorkonfiguriert eine sowohl schlüsselfertige als auch modular anpassbare Internal-Developer-Platform sein.

Unsere Bausteine (Bricks) werden als Helm-Charts im `platform-apps/charts` Verzeichnis ausgeliefert,
und stellen die Basis der kubriX Ditribution dar.

Um die aus unserer Sicht beste, stabilste und sichere Konfiguration, die auch gut mit den den anderen Bausteinen integriert ist,
auszuliefern, benötigt man ein Konzept um einerseits Konfigurationen auszuliefern, die aber auch vom Kunden angepasst und individuell eingesetzt werden können.

## Vorteile unserer Konfigurationsstruktur

Um dieses Ziel zu erreichen, verfolgen wir den Ansatz von modularen Helm Valuesfiles, die sich um spezifische Aspekte kümmern.
Dies hat folgende Vorteile:

- kubriX kann Features, die auch bestimmte Helm Values benötigen, automatisiert ausliefern, und muss nicht manuell beim Kunden auf Basis von Dokumentationen in den kundenspezifischen Values integriert werden
- Kunden können ihre kundenspezifischen Values über eigene Valuesfiles erweitern, und es ist sofort sichtbar was vom Produkt, und was vom Kunden kommt.
  Damit ist es auch möglich Werte von kubriX zu überschreiben, wenn diese beim Kunden so nicht sinnvoll sind.
- modulare aspektorientierte Valuesfiles ermöglichen auch Konfigurationen auszuliefern, die nur in bestimmten Umgebungen (Cluster-Typen, Cloud-Providern) sinn machen
- Mehrfachkonfigurationen werden vermieden, weil Konfigurationen nicht aus unterschiedlichen Valuesfiles zusammenkopiert werden müssen, sondern von den jeweiligen Valuesfiles herangezogen werden (DRY-Prinzip)
- alternativ könnte ein einziges Valuesfile als Template definiert werden, das wird aber erfahrungsgemäß sehr komplex, nicht mehr Wartbar, und kann aufgrund seiner dynamischen Elemente nicht mehr mit statischen Codeanalyse-Tools wie `helm lint` geprüft werden

## Herausforderungen

Es gibt aber auch Herausforderungen, wenn man Helm Values auf mehrere Valuesfiles verteilt:

- Überblick bewahren, welche Values durch welche Valuesfiles ziehen und wie schlussendlich das gerenderte Ergebnis aussieht
- Listen (Arrays) können nicht partiell überschrieben werden, sondern müssen immer komplett kopiert werden, wenn sich darin auch nur Teile ändern

Um diese Herausforderungen zu meistern:

- entsprechende Tools, die das Ergebnis aller Values anzeigt (computed values) und ihre Konfigurationsherkunft
- gerenderte Charts in CI-Pipeline als PR-Kommentar
- wo man selbst entscheiden kann: Maps statt Listen bevorzugen, damit nicht ganze Listen kopiert werden müssen

## Arten und Reihenfolgen der Valuesfiles

Die folgende Tabelle listet die Valuesfiles nach ihrer Priorität auf (d.h. spätere Valuesfiles können vorherige überschreiben).
Alle diese Values-Files sind optional, d.h. im einfachsten Fall besteht ein Helm-Chart nur aus einem leeren values.yaml.
Damit ziehen die Default-Werte aller abhängigen Sub-Charts.

| Zweck | Filepattern | Beispiele für Filenamen | Installationsvariable
|---|---|---|---|
| Sinnvolle Defaults | values-kubrix-default.yaml | - | - |
| Clustertyp spezifische Werte | values-cluster-${clusterType}.yaml | values-cluster-kind.yaml, values-cluster-okd.yaml, values-cluster-gardener.yaml  | KUBRIX_CLUSTER_TYPE |
| Cloud-Provider spezifische Werte | values-provider-${cloudProvider}.yaml | values-provider-metalstack.yaml, values-provider-aks.yaml, values-provider-eks.yaml | KUBRIX_CLOUD_PROVIDER |
| HA-spezifische Konfiguration | values-ha-enabled.yaml | - | KUBRIX_HA_ENABLED |
| Sizing | values-size-${tShirtSize}.yaml | values-size-small.yaml, values-size-small.yaml, values-size-small.yaml | KUBRIX_TSHIRT_SIZE |
| Höhere Sicherheit als Default | values-security-strict.yaml | - |KUBRIX_SECURITY_STRICT |
| kundenspezifische Konfiguration, während Bootstrap generiert (sollte vom Kunden nicht verändert werden) | values-customer-generated.yaml | - | KUBRIX_REPO, KUBRIX_DOMAIN, KUBRIX_DNS_PROVIDER, KUBRIX_GIT_USER_NAME, KUBRIX_CUSTOM_VALUES
| kundenspezifische Konfiguration, die manuell vom Kunden gepflegt wird | values-customer.yaml | - | -

> 💡 **Info:** Falls erforderlich, könnten bestimmte Aspekte auch in einem Valuesfile kombiniert sein, z.B. "XL-Sizing für hochverfügbare Topologie",
falls die HA-Topologie andere Komponenten benötigt, wo sich auch die Sizing-Konfiguration ändert.

# Definition des Gesamt-Stacks

Um zu definieren welcher Gesamt-Stack mit welchen Values installiert werden soll, wird ein sogenannter "Target-Type" definiert (entspricht einem Kubrix-Stack).
Er wird im `platform-apps/target-chart` im Valuesfile `values-${targetType}.yaml` definiert.

Dieser Target-Type kann sehr generisch und variable sein (für mehrere Anwendungsfälle aber möglicherweise komplexer), oder sehr konkret auf einen spezifischen Anwendungsfall (nur für einen konkreten Anwendungsfall, aber dafür leicht zu lesen). Über die Installationsvariable KUBRIX_TARGET_TYPE wird bestimmt, welcher Stack installiert werden soll.

Welche oben genannten Valuesfiles der Helm-Charts in diesem Stack herangezogen werden, wird im `.default.valuesFiles` bestimmt. 

Sollen alle oben genannten Valuesfiles je nach Installationsvariablen herangezogen werden, muss `.default.valuesFiles` wiefolgt definiert sein:

```
default:
  valueFiles:
  - values-kubrix-default.yaml
  - values-cluster-{{ .kubriX.clusterType }}.yaml
  - values-provider-{{ .kubriX.providerType }}.yaml
  {{ if .kubriX.highAvailability }}
  - values-ha-enabled.yaml
  {{ end -}}
  - values-size-{{ .kubriX.tShirtSize }}.yaml
  {{ if .kubriX.strictSecurity }}
  - values-security-strict.yaml
  {{ end -}}
  - values-customer-generated.yaml
  - values-customer.yaml
```

Weiters kann im `.applications` Attribut ein Chart je nach Installationsvariable ein- oder ausgenommen werden. Beispiel:

```
  # installiere ingress-nginx nicht wenn der Clustertyp `kind` ist.
  {{ if ne .kubriX.clusterType "kind" -}}
  - name: ingress-nginx
    annotations:
      argocd.argoproj.io/sync-wave: "-11"
  {{ end -}}

  # installiere aks-data-collector nur wenn der Cloudprovider `aks` ist.
  {{ if eq .kubriX.cloudProvider "aks" -}}
  - name: aks-data-collector
    annotations:
      argocd.argoproj.io/sync-wave: "-5"
  {{ end -}}
```

Zusätzlich kann mit der Installationsvariable `KUBRIX_APP_EXCLUDE` eine gewisse Applikation aus der `.applications` Liste entfernt werden.
Damit spart man sich die komplexeren `If` Abfragen.

> 💡 **Info:** die Variablen in den Valuesfiles können nur während dem Bootstrap-Prozess gerendert werden, d.h. wenn die Installationsvariable `KUBRIX_BOOTSTRAP` auf `true` gesetzt ist.








