# Onboarding apps in a gitops way

* Status: DRAFT
* Deciders: sX CNP oss Team
* Date: 2023-05-29

This ADR depends also on ADR "001-gitops-onboarding-teams".
In the different solution options we mention for which "onboarding teams" options this option is applicable.
Some are applicable to all team-onboarding-scenarios, some are just for specific team-onboarding scenarios.

In the future we can probably draw this decision tree on a map in the future.

## Context and Problem Statement

As a
***dev-team***
I want to onboard and maintain my app as a self-service without high friction and wait times.
Still, I want to apply all platform-requirements and restriction with as much automation as possible.

Normally onboarding teams and apps includes creating:
  - argocd app-project with restrictions (source-Repos, destinations, clusterResourceWhitelist, namespaceResourceBlacklist, ...) and roles if needed
  - argocd app
  - app namespaces
  - default configuration inside namespaces (limit-ranges, quotas, deny-all network-policies)
  - maybe some additonal platform-services (e.g. observability-tool ) also need to be configured for the new team/application/namespace (this isn't addressed in this ADR for now)

Depending on the solution some of this parts are done by the platform-team, by the dev-team, or automatically.

## Decision Drivers

- high self-service and low friction for dev-teams
- security-standards / multi-tenant configurations in place
- since not all teams have the same knowledge, some low-knowledge teams and also high-knowledge teams should get their best solution
- the solution should fit also to different "operator deployment patterns" and "promotion patterns"

## Considered Options

* self-service app and app-namespace onboarding
* ApplicationSet with simple "deployment descriptor"
* ApplicationSet with Parent-Helm-Chart
* ApplicationSet with config.json representing a Parent-Helm-Chart
* Central gitops-Repo for app and app-namespace onboarding
* App onboarding for namespace-scoped argocd instance

## Decision Outcome

We should explore which option is the best for which team and provide different show cases.
Also, we should find out if we can support multiple approaches on one platform.

Which options are best for these user-stories?

As a 
**dev-team without deep knowledge in argocd, kustomize, helm and kubernetes manifest**
I want to onboard my app with a very slim and easy API and as much sane defaults as possible
and strong governance to prevent any problems because of limited knowledge.

suggested options: tbd

As a
**dev-team with lots of knowledge in kubernetes, argocd, kustome and helm**
I want to onboard my app with high flexibility and with less governance as possible
to make use of any configuration mgmt tools and kubernetes manifests which are possible.
Still, I want a platform-team responsible for the cluster and the cluster is used by multiple dev-teams,
not just dedicated for one dev-team.

suggested options: tbd

As a
**dev-team with lots of knowledge in kubernetes, argocd, kustome and helm**
I want to onboard my app with high flexibility and with less governance as possible
to make use of any configuration mgmt tools and kubernetes manifests which are possible.
The cluster is dedicated for my team, but I still want a platform-team which is responsible for the cluster-mgmt.

suggested options: tbd

As a
**dev-team with lots of knowledge in kubernetes, argocd, kustome and helm**
I want to onboard my app with high flexibility and with less governance as possible
to make use of any configuration mgmt tools and kubernetes manifests which are possible.
The cluster is dedicated for my team and I take full responsibility for this cluster.
I use or copy some basic configurations from a platform-team but treat them more as a good practice which I can use or not.

suggested options: tbd


### Consequences

## Validation

## Pros and Cons of the Options

### self-service app and app-namespace onboarding

Only applicable for team-onboarding option "Apps-in-any-Namespace and Multi-Tenant Kyverno-Policies"!
If you use this in a central argocd instance without "apps-in-any-namespace" there is a privilege-escalation-risk 
because the child-app in the app-of-apps repo can use any argocd app-project in this argocd instance and can deploy in any namespace (see https://github.com/argoproj/argo-cd/issues/2785)!

Dev-team creates a new argocd app-definition in their app-of-apps gitops-repo.
Therefore the platform-team needs to define a app-of-apps definition upfront which points to this gitops-repo.

ApplicationSets-in-any-namespace are also possible with some restrictions: https://github.com/suxess-it/kubriX/issues/181
So Dev-Teams can create their own ApplicationSets without a platform-team. Without "Apps-in-any-Namespace" ApplicationSets were also only safe when platform-teams defined them, otherwise dev-teams could use any argocd app-project.

Example:
https://github.com/suxess-it/kubriX/blob/ee5d680e315a5b054b9b1833194fbe70826d2585/platform-apps/charts/team-onboarding/values-k3d.yaml#L13-L16
and https://github.com/suxess-it/team1-apps/tree/main/k3d-apps 

pros:
- very high self-service for dev-teams without the need of a central managed applicationset
- no privilege escalation for dev-teams app-definitions possible, they need to stay in the teams app-project
- high standardization, security and soft-multi-tenancy standards for the namespaces because of kyverno generate policies for each namespace
- gitops-repo of the platform-team keeps quite manageable, because not every app-definition needs to be in this central gitops-repo

cons:
- apps-in-any-namespace is still beta, although it seems very stable
- applicationsets then have some restrictions (also when used by the platform team), see https://github.com/suxess-it/kubriX/issues/181
- dev-team needs to have high knowledge of argocd app-definitions (could be enhanced with backstage scaffolder templates)

### ApplicationSet with simple "deployment descriptor"

Applicable for all team-onboarding options!

Platform-team creates an application-set per team during team-onboarding with static argo project reference.
[SCM Provider generator](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-SCM-Provider/) or [Git generator](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Git/) (depending of your repository pattern)

Dev-Team creates their gitops-repos with highly simplified "deployment descriptor", which is in fact a helm values-file.
The Helm-Chart is stored in a different place (helm repo, git repo) managed by the platform team.
The Helm-Chart is very flexible configurable via the values file and has lots of sane defaults.
If you are fine with the sane defaults, you have a small values file, if you need special things, you have a bigger values file.

Example:

- [ApplicationSet with SCM-Provider](https://github.com/suxess-it/kubriX/blob/main/team-apps/onboarding-apps-charts/multi-stage-app-with-kargo-pipeline/README.md#applicationset-with-scm-provider)
- [gitops-repos with simple deployment file (which also creates multi-stage apps and kargo resources)](https://github.com/suxess-it/team1-demo-app1/blob/main/app-stages.yaml)

pros:
- Dev-team only need a very simple value file. With sane defaults the value files content can be pretty small
- Dev-teams don't need helm or kubernetes resource manifests knowledge
- very slim and easy (but not so flexible) API
- new Parent-Chart versions rollout very fast (but you need to take care about staging and backward-compatibility)

cons:
- Dev-team has no option to define which K8s manifests and cannot add some additional resources.
- This option is always inflexible for bigger requirements, no matter how flexible the base-chart is
- maybe too less insights what is really going on for dev-teams (probably a matter of documentation and links to the base-chart)
- live-cycle-mgmt for the base-chart is hard, because changes need to be backward-compatible, since no version specification of the base-chart possible
- there is no source-of-truth in the dev-team gitops-repo, so deploying new versions of the app in the dev-stage can end in different results than in prod because the parent-chart is different between dev and prod

### ApplicationSet with Parent-Helm-Chart

Applicable for all team-onboarding options!

Platform-team creates an application-set per team during team-onboarding with static argo project reference.
[SCM Provider generator](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-SCM-Provider/) or [Git generator](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Git/) (depending of your repository pattern)

Dev-team creates gitops-repos containing a parent-helm-chart just with a values-File and referenced Sub-Chart,
which is maintained by a platform-team or some other base-chart maintainers.

Namespace-Creation-Self-Service is only possible with Kyverno-Generate-Policies!

Example: tbd

pros:
- dev-team knows better which other manifests get created, as long it knows the sources of the sub-chart
- dev-team can specify the version of the chart (renovate helps with updates)
- dev-team can add additional resources in the parent-charts templates-Folder

cons:
- since applicationsets are templates every application in this applicationset has very similar attributes (needs to be explored)

### ApplicationSet with config.json representing a Parent-Helm-Chart

Applicable for all team-onboarding options!

Platform-team creates an application-set per team during team-onboarding with static argo project reference.
Dev-team creates a gitops-repo containing a config.json with definitions for helm repo, chart and version can be placed (todo: can this be implemented as optional with the same appset of option 1 or is it then mandatory).

Namespace-Creation-Self-Service is only possible with Kyverno-Generate-Policies!

Example: https://github.com/thschue/gitops-demo/tree/main/demo

pros:
- dev-team doesn't need to know the helm structure (but needs to know our own config.json format)
- kubernetes resource best practices can be implemented centrally in this parent-chart

cons:
- config.json is proprietary, no "helm template" works out-of-the box and no renovate update
- since applicationsets are templates every application in this applicationset has very similar attributes (needs to be explored)


### Central gitops-Repo for app and app-namespace onboarding

Applicable only for team-onboarding option "Central gitops-Repo for app-projects, apps, namespaces and default configurations"

dev-team creates app-definition in argocd namespace via PR in central gitops-repo which represents the argocd apps.
platform-team needs to review the PR for every app definition if the correct argo project is referenced.

Example: tbd

pros:
- tbd

cons:
- central gitops-repo can get quite large and with lots of applications a dev-team could lose overview


### App onboarding for namespace-scoped argocd instance

Applicable only for team-onboarding option "Seperate namespace-scoped argocd instance for every team"

Dev-team creates a new argocd app-definition in their app-of-apps gitops-repo.
Therefore the platform-team needs to define a app-of-apps definition upfront which points to this gitops-repo.

Dev-team can create their argo projects by themselves or use default project since it is limited by the scope of the namespace-scoped instance. 
Additional namespaces need to be requested from the platform-team, since the namespaced-scope argocd is pinned to specific namespaces.

Example: tbd

pros:
- new apps is a complete self-service
- dev-team can make use of any configuration mgmt tools and kubernetes manifests which are possible

cons:
- new namespaces is not a self-service (compared to app-in-any-namespace)


# More information

These user stories are ordered by expertise of the platform consumers:

- little skills and knowledge - high standardization and governance
- medium skills and knowledge - high standardization, governance, but more flexibility and insights
- high skills and knowledge - very flexible, still some governance where needed and lots of insights

and the self-service capability of the platform

- namespace / project / tenant as a service
- ticket / PRs to platform-team and reviews required per app

Disclaimer: as always, enabling and "skill-up" dev-teams is always an advantages.
Still, some dev-teams are not able to skill them up or don't have enough resources.
Maybe, when this dev-teams get more experience their requirements towards more insights and flexibility
and less governance changes.
Also, maybe insights (which kubernetes-manifests are created, where do we have problems) are always helpful.
Then not so experienced teams can learn from the insights they get.
On the other way, also for experienced teams the platform should be easy to use, but not limiting in solutions.
That is all about golden paths instead of golden cages.
