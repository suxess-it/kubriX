# Centralized RBAC with OIDC Integration (kubriX Prime Feature)

## User and Team Management in kubriX

Centralized user and team management is a key feature of kubriX. We use Keycloak as the single source of truth for all user identities on the platform. kubriX integrates with the OIDC functionality of supported applications to ensure consistent and centralized authentication and authorization.

kubriX allows you to connect its integrated Keycloak instance with your existing IAM system (e.g., external Keycloak, LDAP, Active Directory, GitHub), enabling automated user and group synchronization via identity brokering or federation.

## Example Configuration

The team-onboarding Helm chart is the main entry point for all team-related resources in kubriX. It defines users, roles, and access permissions using a single values.yaml file. Secrets are managed and synced using the External Secrets Operator (ESO).

```
platformteam:
  admins:
    - backstageadmin
    - demoadmin
  editors:
    - phac
    - jokl
  viewers:
    - demouser

teams:
  - name: teamx
    admins:
      - teamadmin
    editors:
      - demoeditor
    viewers:
      - demoviewer
    sourceRepos:
      - '*'
    clusterResourceWhitelist:
      - group: ""
        kind: Namespace
      - group: kargo.akuity.io
        kind: Project
    appOfAppsRepo:
      repoURL: https://github.com/suxess-it/teamx-apps
      path: uibklab-apps
      revision: main
    multiStageKargoAppSet:
      github:
        organization: kubrix-demo
```
## platformteam Configration Explained

This configuration configures platformwide user configuration:

* **admins**: Full control to create, modify, and delete resources and metadata
* **editors**: Can list and modify resources and metadata
* **viewers**: Read-only access to resources, limited metadata visibility

````
⚠️ Note: when using platformteam config - please remove members from keycloak values file group setting
````

## teams Configration Explained

This configuration creates a team called teamx with specific user roles for team configuration:

* **admins**: Full control to create, modify, and delete resources and metadata
* **editors**: Can list and modify resources and metadata
* **viewers**: Read-only access to resources, limited metadata visibility

## Configured Integrations

### Vault

A Helm template file (vault_keycloak.yaml) generates the necessary Keycloak resources (group, roles, clients, and mappers). It links the Keycloak group to a Vault identity entity via group-alias. Vault policies are generated and attached to the identity group, limiting access strictly to the team’s own secrets and paths. For convenience other directories are listed, but these secrets are not visible.

### ArgoCD

Teams are translated into ArgoCD Projects. Each project enforces a sourceRepos and clusterResourceWhitelist policy. These ensure that teams can only deploy apps from their defined Git repositories and to approved Kubernetes resources. Role bindings in ArgoCD reference the Keycloak group (OIDC), allowing seamless access control. Control and visibility for Applications only, where user is defined in values file.

### Grafana

The grafana_keycloak.yaml template generates Grafana teams with the same name as the Keycloak group. Folder structures for each team are created automatically. Folder-level access is scoped using FolderPermission resources. Viewer access to general folders is assigned by default. Grafana does not manage members declaratively, so a sync controller is provided (see next section).


## Auto-Healing and Team Sync

kubriX includes auto-reconciliation logic for Grafana teams. If a team is accidentally deleted from Grafana (e.g., via UI), the following components restore it:

team-sync.yaml: Recreates teams and their folder structures based on Git-defined state. Also ensures folder permissions are consistent. For sync-script uses the attribe "kubrix.io: grafanaimport", coming from kubrix keycloak(attached to users during first idp login).

team-sync-es.yaml: Enhances syncing by triggering reconciliation through External Secrets events. If a secret or mapping changes, the sync logic is re-applied automatically.
````
⚠️ Note: kubrix Grafana Team Sync runs every 5 minutes. On first login, it may take up to 5 minutes before synchronization is complete.
````
This ensures that user-to-team mappings and team-level permissions stay intact even after accidental removal, especially helpful when SSO users are dynamically added to teams outside Git.

## Related Resources and Templates

Vault + Keycloak Setup Template: Manages Keycloak group creation, client scopes, protocol mappers, and Vault group alias bindings. Sets Vault policies for secrets access.

Grafana + Keycloak Group Setup Template: Creates a Grafana team for each Keycloak group and provisions team-specific folder structures and permissions.

Grafana Team Sync Template: Watches team definitions and ensures Grafana reflects the Git-defined structure even if teams/folders are removed.

Grafana Team Sync with External Secrets: Triggers folder and team reconciliation automatically when related secrets (e.g., SSO token, user mapping) change.

This RBAC integration enables kubriX teams to work securely and efficiently with clear, automated boundaries around their resources and access scopes.

## Links:

Why we prefer teams/folders to Organisations
- https://grafana.com/blog/2022/03/14/how-to-best-organize-your-teams-and-resources-in-grafana/
- https://grafana.com/blog/2024/09/10/grafana-access-management-how-to-use-teams-for-seamless-user-and-permission-management/#how-to-conquer-access-management-at-scale