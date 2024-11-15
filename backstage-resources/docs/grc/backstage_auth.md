# Authentication/Integration in Backstage

This document should give an overview how Backstage Authentication/Integration works in kubriX Environment

backstage.io documentation link: 
- [Authorization](https://backstage.io/docs/auth/)
- [Integration](https://backstage.io/docs/integrations/)

## Authorization
### Purpose
- Sign-in and identification of users
- Delegating access to 3rd party resources

There are several build-in auth providers, also custom providers are possible. Only "one" will/should be used for sign-in, the rest provide access to external resources.
For different showcases we have currently 2 providers active in our kubriX demo - GitHub and OIDC via Keyloak Instance

```
auth:
    environment: development
    providers:
        github:
            development:
                clientId: ${GITHUB_CLIENT_ID}
                clientSecret: ${GITHUB_CLIENT_SECRET}
        oidc:
            development:
                metadataUrl: http://keycloak-service.keycloak.svc.cluster.local:8080/realms/sx-cnp-oss #.well-known/openid-configuration can be ommited
                callbackUrl: https://backstage.lab.suxessit.k8s.cloud.uibk.ac.at/api/auth/oidc/handler/frame
                clientId: backstage
```
GitHub secrets created by oauth app, alternativly they can get created by GitHub App:

#### HINT
[backstage.io documentation link](https://backstage.io/docs/integrations/github/github-apps)

    Difference between GitHub Apps and GitHub OAuth Apps
    GitHub Apps handle OAuth scope at the app installation level, meaning that the scope parameter for the call to getAccessToken in the frontend has no effect. When calling getAccessToken in open source plugins, one should still include the appropriate scope, but also document in the plugin README what scopes are required for GitHub Apps.

Autorization Needs Frontend and Backend configuration
- Backend: https://backstage.io/docs/auth/identity-resolver/
- Frontend: SignInPage

### Scenario Examples
- Authenticate Users to Backstage using their Github accounts
  - User Login
- Perform API Actions on behalf of authenticated users, utilizing their permissions
  - Opening a PR or creating an Issue in behalf of a user
- Access data that may require user specific scopes or to act as the user
  - User repositories, contributions

#### Required Scopes
- read:user: Access basic profile information
- user:email: Access the user’s email addresses
- repo: Access private repositories (if needed)
- workflow: Access GitHub Actions workflows (if needed)
- write:discussion: For creating or managing discussions (if your Backstage setup involves GitHub Discussions)

### Scaffolder
Integrated by default 
[backstage.io documentation link](https://backstage.io/docs/auth/identity-resolver)
    
### Token issuer
Authentication backend generates and manages its own signing keys automatically for any issued backstage token
The have short lifetime and do not persist after instance restarts!

tbd - solution for this 
[backstage.io documentation link](https://backstage.io/docs/auth/#configuring-token-issuers)

## Integrations

### Purpose:
- Service account for automated GitHub API Requests
- Allow Backstage to read or publish data using external providers (Github, Gitlab,…)
- Performing static, non-user-specific tasks, such as reading repo data, fethcing org information or indexing repos

For github (located at root level in app-config.yaml since it is used by many Backstage core features)
```
integrations:
    github:
    - host: github.com
        token: ${GITHUB_TOKEN}
```

### Scenario Example
- Github discovery processor
  - Scanning Github Repos for catalog files
- Github API requests
  - Where admin don't want user specific access
- CI/CD pipelines interacting with GitHub via Backstage
- Backstage scanning GitHub repos and does not need user authentication (sign-in)
- Running Github integration Plugin, that requires persistent access to certain data
- Fetching GitHub Actions logs for a Backstage plugin: Use a PAT with workflow scope.

#### Required Scopes
- repo: Full control of private repositories (read/write)
- read:org: Read access to organization membership
- admin:org: If the token needs to manage organization settings (rare)
- read:discussion: To read GitHub Discussions
- workflow: To access workflow runs and logs
- write:packages: If interacting with GitHub Packages

## GitHub comparison 
|Feature|GitHub OAuth App|GitHub PAT|
| ------ | ------ | ------ |
|User Athentication|✅ Yes|❌ No|
|Delegated User Permission|✅ Yes(based on user scopes)|❌ No|
|Access to Private Repos|✅ Yes(if user grants access)|✅ Yes (with repo scope)|
|Machine to GitHub API Access|❌ Limited (depends on user)|✅ Yes (using Service Account)|
|CI/CD integration|❌ No, not ideal!|✅ Yes|
|Setup Complexity|Medium|Low|

## Best Practices Shorty
- Use **OAuth App** for user-related actions, user authentication, and any actions that need to happen on **behalf of a user**.
- Use **PAT** for service-level access where **user context is not required**, such as scanning repositories, reading data, or performing automated tasks.
