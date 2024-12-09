# Onboarding teams

New teams can simply onboard themselves by [executing the 'team-onboarding' template)[https://backstage.demo.kubrix.cloud/create/templates/default/team-onboarding] or by clicking "Choose" in the "Team-Onboarding" template here: https://backstage.demo.kubrix.cloud/create

pic: team-onboarding-1.png

The team name is automatically selected based on your assigned group, so just click on 'Next'

pic: team-onboarding-2.png

The host, organization and path to your kubriX platform Git-Repo is also automatically select, so just click on 'Next'

pic: team-onboarding-3.png

On the summary page review your data and click on 'Create'

pic: team-onboarding-4.png

Backstage creates a Pull-Request for you to add your team to the team-onboarding chart. This PR needs to get reviewewd and merged by the platform-team.

Also, your team gets their own "App-Of-apps" Git-Repo where you can put your own ArgoCD application definitions in the created 'demo-apps' folder.

pic: team-onboarding-5.png

What you will see in the Pull-Request 'Files changed" tab, is a new stanza for your team.
With these values the team-onboarding chart creates:

* a new ArgoCD project with defined allowed sourceRepos, clusterResourceWhitelist and destinations.
* some predefined platform AppSet SCM-Generators which search for some specific git-Repos of your team.

If you are interested in the specific Kubernetes Resources which would get created with this PR
you can have a look at the automatically created PR comments "Changes Rendered Chart".

When your platform team merges the PR and everything gets synchronized by ArgoCD 
your application team can deploy new applications in a complete self-service way!

Some background information can also be found in the 'Onboarding teams and apps' chapter.


