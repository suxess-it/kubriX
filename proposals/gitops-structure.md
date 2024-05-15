# gitops structure

# alternative title "gitops process and repos"

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

- operator deployment pattern: https://cloudogu.com/en/blog/gitops-repository-patterns-part-2-operator-deployment-patterns
- repository pattern: https://cloudogu.com/en/blog/gitops-repository-patterns-part-3-repository-patterns
- promotion pattern: https://cloudogu.com/en/blog/gitops-repository-patterns-part-4-promotion-patterns
- wiring pattern: https://cloudogu.com/en/blog/gitops-repository-patterns-part-4-promotion-patterns

Maybe this proposal (or ADR) focuses more on the [wiring](https://cloudogu.com/en/blog/gitops-repository-patterns-part-4-promotion-patterns) part, especially how new teams and apps can be onboarded.

And maybe there are also some mixed solutions possible with some variants. Lets see where it brings us.

Maybe this document ends in a decision tree where you come to your perfect solution based on some decisions down the road.

# team-onboarding via platform-repo, application onboarding self-service/automatically

## implementation technology

applicationsets  and argo project per team

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
