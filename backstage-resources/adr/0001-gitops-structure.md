# gitops process and repos


# TODO reminder

break the user-stories in two parts:

- team-onboarding
  - platform-team creates ns in central repo
  - apps-in-any-namespace approach
- application-onboarding
  - App-Of-Apps
  - ApplicationSets (with already mentioned variants)

# articles and resources

https://github.com/cloudogu/gitops-patterns
https://github.com/akuity/awesome-argo
https://cloudogu.com/en/blog/gitops-repository-patterns-part-1-introduction

# Introduction

this document is a starting point
describing different approaches for gitops structures,
repos and processes.
Goal is to find gitops solutions
and describe which one fits to which purpose with pros and cons.

Be aware that there are many different gitops solutions,
because your whole solution includes:

- [operator deployment pattern](https://cloudogu.com/en/blog/gitops-repository-patterns-part-2-operator-deployment-patterns)
- [repository pattern](https://cloudogu.com/en/blog/gitops-repository-patterns-part-3-repository-patterns)
- [promotion pattern](https://cloudogu.com/en/blog/gitops-repository-patterns-part-4-promotion-patterns)
- [wiring pattern](https://cloudogu.com/en/blog/gitops-repository-patterns-part-5-wiring-patterns)

Maybe this ADR focuses more on the [wiring](https://cloudogu.com/en/blog/gitops-repository-patterns-part-4-promotion-patterns) part, especially how new teams and apps can be onboarded.

And maybe there are also some mixed solutions possible with some variants. Lets see where it brings us.
Maybe this document ends in a decision tree where you come to your perfect solution based on some decisions down the road.

TODO: currently it is not clear if solutions in those categories are independent from each other
or if they depend each other.



# Onboarding teams

## Context and Problem Statement

As a
***platform-team***
I want a mechanism where I can onboard new teams and applications to a cluster with all required policies
so that stability/security of the platform is still guaranteed and no negative effects to other teams and applications arise.

Normally onboarding includes creating:
  - argocd app-project with restrictions (source-Repos, destinations, clusterResourceWhitelist, namespaceResourceBlacklist, ...) and roles if needed
  - argocd app
  - app namespaces
  - default configuration inside namespaces (limit-ranges, quotas, deny-all network-policies, kyverno-policies, roles/bindings, ...)

Depending on the solution some of this parts are done by the platform-team, by the dev-team, or automatically.

**Options**

***Option 1***

The dev-team creates a ticket for onboarding to the platform-team. platform-team creates the configurations by themselves without a possibility for devs to create PRs.

***Option 2***

The platform-team has a gitops-repo with helm or kustomize. dev-teams create PRs to this gitops-repo and the platform-team reviews this PRs and merges them (maybe some additional automatic checks/pipelines help with reviewing the PR).

***Option 3***

The platform-team onboards just the team by creating an argocd app-project for this team and a dedicated app-definition-namespace for this app-project. 
  The dev-team can then create new apps and app-namespace by themselves without interacting with the platform-team. This can be established with [apps-in-any-namespace](https://argo-cd.readthedocs.io/en/stable/operator-manual/app-any-namespace/). <br>
  To onboard a new dev-team, the platform-team
  - extends the [value application.namespaces](https://github.com/argoproj/argo-helm/blob/3174f52ffcfe3bb0d2ad6118411eacbaf20b0c7d/charts/argo-cd/values.yaml#L276) with a "app-definition namespace" for this team (e.g. "team1-app-definitions" )
  - creates this "app-definition namespace" for this team (e.g. "team1-app-definitions")
  - creates an argocd app-project for this team (e.g. team1-project), references the "app-definition namespace" in the projects sourceNamespaces attribute, sets the destinations in the project to valid "workload namespaces", like "team1-*" and sets clusterResourceWhitelist to "kind: Namespace".
  - creates some mutating kyverno-policies to create some [multi-tenancy policies](https://kyverno.io/policies/?policytypes=Multi-Tenancy) automatically for new namespaces

  For onboarding the apps there are again some different options, therefore we discuss this app-onboarding options in the next section:

# Onboarding apps

## Context and Problem Statement

As a
***dev-team***
I want to onboard and maintain my app as a self-service without high friction and wait times.
Still, I want to apply all platfprm-requirements and restriction with as much automation as possible.

**Options**


***option 1***

For onboarding a new app, the dev-team creates a new argocd app definition in their app-of-apps gitops-repo.
The platform-team therefore needs to define a app-of-apps definition upfront which points to this gitops-repo.

This option is only secure with "Onboarding teams - option 3", because otherwise the child-app in the app-of-apps repo can use any argocd app-project in this argocd instance and can deploy in any namespace (see https://github.com/argoproj/argo-cd/issues/2785)

An example for this solution is in https://github.com/suxess-it/sx-cnp-oss/blob/12883d99657732d145d2992afa21b554403abd37/platform-apps/charts/argocd/values-k3d.yaml#L14

So the dev-team can create new apps by their own in their "app-definition namespace" and set the sync option "CreateNamespace".
As long as the namespace name matches the valid destinations in the argo project (team1-*) the namespace gets created.
As described in "Onboarding teams - option 3" kyverno policies create some default-configurations for this namespace, to be multi-tenant-aware.
Additionally [Namespace Metadata](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-options/#namespace-metadata) can be used to apply different kyverno policies based on some labels or annotations.

Application-sets-in-any-namespace are also possible with some restrictions: https://github.com/suxess-it/sx-cnp-oss/issues/181
So Dev-Teams can create their own ApplicationSets without a platform-team. Without "Apps-in-any-Namespace" ApplicationSets were also only safe when platform-teams defined them, otherwise dev-teams could use any argocd app-project.

Kargo Projects are possible with a special kyverno policy which checks the [kargo project name against the allowed argocd app-project destinations](https://github.com/suxess-it/sx-cnp-oss/blob/main/platform-apps/charts/kyverno/templates/policy-kargo-project-name-validation-apps-in-any-ns.yaml).


***option 2***

platform-team creates an application-set per team during team-onboarding with static argo project reference.
dev-team create their gitops-repos with highly simplified "deployment descriptor".
The additional K8s manifests are stored in a different place (helm repo, git repo) managed by the platform team.
Dev-team has no option to define which K8s manifests and cannot add them.


***option 3***

dev-team creates a gitops-repo containing a parent-helm-chart just with a values-File and referenced Sub-Chart, which is maintained by the platform-team.
dev-team knows what other manifests get created and can specify the version of the chart (renovate helps with updates)


***option 4***

dev-team creates a gitops-repo containing a config.json with definitions for helm repo, chart and version can be placed (todo: can this be implemented as optional with the same appset of option 1 or is it then mandatory).<br>
implementation: https://github.com/thschue/gitops-demo/tree/main/demo

in option 2,3 and 4 not so much argocd, kustomize, helm or kubernetes manifest knowledge is needed. more knowledge, more flexibility.

As a 
**dev-team without deep knowledge in argocd, kustomize, helm and kubernetes manifest**
I want to onboard my app with a very slim and easy API and as much sane defaults as possible
and strong governance to prevent any problems because of limited knowledge.

TODO: are there also Kustomize implementations for this approaches?
What advantages has a helmfile instead of a parent-chart).
https://helmfile.readthedocs.io/en/latest/

***option 5*** 

dev-team creates app-definition in argocd namespace via PR in gitops-repo which represents the argocd apps.
platform-team needs to review the PR for every app definition if the correct argo project is referenced.


***option 6***

dev-team gets its own namespaced-scoped argocd instance. namespaced-scoped argocd instance can be configured by central cluster-scoped argocd via gitops. if this argocd instance should also manage some additional namespaces we need additional configs/roles/bindings which is probably best managed with argocd operator (or openshift gitops operator on openshift). dev-team can create their argo projects by themselves or use default project since it is limited by the scope of the namespace-scoped instance. pros: higher isolation between teams concerning configurations, auth backend, permissions, resources and scalability, cons: higher resource consumption, higher management overhead, higher deployment complexity.

Example implementations:

https://developers.redhat.com/articles/2022/04/13/manage-namespaces-multitenant-clusters-argo-cd-kustomize-and-helm


Option 5 and Option 6 are for dev teams with this user story:

As a
**dev-team with lots of knowledge in kubernetes, argocd, kustome and helm**
I want to onboard my app with high flexibility and with less governance as possible
to make use of any configuration mgmt tools and kubernetes manifests which are possible.
Still, I want a platform-team responsible for the cluster and the cluster is used by multiple dev-teams,
not just dedicated for one dev-team.


***option 7***

As a
**dev-team with lots of knowledge in kubernetes, argocd, kustome and helm**
I want to onboard my app with high flexibility and with less governance as possible
to make use of any configuration mgmt tools and kubernetes manifests which are possible.
The cluster is dedicated for my team, but I still want a platform-team which is responsible for the cluster-mgmt.

***option 8***

As a
**dev-team with lots of knowledge in kubernetes, argocd, kustome and helm**
I want to onboard my app with high flexibility and with less governance as possible
to make use of any configuration mgmt tools and kubernetes manifests which are possible.
The cluster is dedicated for my team and I take full responsibility for this cluster.
I use or copy some basic configurations from a platform-team but treat them more as a good practice which I can use or not.










# Old Content, maybe we integrate that later





## User Stories

TODO: maybe those are some pros/cons for the different approaches

These user stories a ordered by expertise of the platform consumers:

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



# TODO: maintaining / changing apps is different in each options above, we should highlight how this works then

# centrally controlled team-onboarding, self-service app onboarding 

team-onboarding via platform-repo, application onboarding self-service/automatically

Seems to be like
- User Story 1, option 4
- User Story 2, option 2 

## environemnt

Can be applied on the operator deployment pattern "Instance per Cluster" or "Hub and Spoke"

With the "instance per namespace" pattern this solution is probably not so useful,
because there the team-isolation is more on per-argocd-instance then on per-argo-project.
However, the app onboarding via applicationsets can be applied also on this pattern. 

## process

1. when onboarding the new team, the platform-team creates
    1. an argo project, so resource whitelists / blacklists / rbac can be defined by platform team
    2. applicationset with 
[SCM Provider generator](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-SCM-Provider/) or [Git generator](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Git/) (depending of your repository pattern)
and using the defined argo project in step 1

    since this is also done via gitops, the dev-team could also create a PR in a central platform-repo for this

2. dev-teams create their gitops-repo based on the pattern defined in the applicationset in step 1.2 and the new application is automatically created

## pros

- new applications which match the applicationset pattern are automatically created without any review of a central platform team
- dev-team doesn't need to know the application definition

## cons

- platform-team needs to be fine with onboarding new applications without review. so some governance need to be in place (default policies in namespace, kyverno, netpol, resource-quotas, limit-ranges)
- since applicationsets are templates every application in this applicationset has very similar attributes or attributes need to be imported by config files per gitops-repo

## examples


## further implementation variations

- multiple sources so dev-teams only need to have some values in their repo and the chart is placed at some other place - see 'multiple sources' solution

- not only automatically app creation, but also kargo resources, namespace with some default resources, ... 


# team and application onboarding in central platform-repo, simple values, renders additional resources

like ARZ solution: 

simple values in central repo
not only automatically app creation, but also kargo resources, namespace with some default resources, ... 

be aware that those value files can be really big and onboarding new value files (corresponds to onbarding new teams) also needs a good implementation.(or values-patterns if that is possible now, e.g. values-team-*)


# application in different namespaces

# multiple sources

## examples

https://github.com/jkleinlercher/just-one-yaml-deployment/blob/main/argocd-config/just-one-yaml-applicationset.yaml

# helmfiles

# self-service and governance