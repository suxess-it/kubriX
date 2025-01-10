# Changelog

## 1.0.0 (2025-01-08)


### Features

* add hub and spoke docs ([#910](https://github.com/suxess-it/kubriX/issues/910)) ([84aee04](https://github.com/suxess-it/kubriX/commit/84aee04deb4db80cb4d5e51774086b80daa863c8))
* add release-please ([#953](https://github.com/suxess-it/kubriX/issues/953)) ([9987b64](https://github.com/suxess-it/kubriX/commit/9987b644165e4d7e0a05b3cb91d67e6164a37a12))
* create trivy scan markdown files in trivy-results folder ([#960](https://github.com/suxess-it/kubriX/issues/960)) ([9e217cd](https://github.com/suxess-it/kubriX/commit/9e217cd5487895f53019e3d7a0dbbaf47ad35bf9))
* **deps:** update helm release ingress-nginx to v4.12.0 ([#952](https://github.com/suxess-it/kubriX/issues/952)) ([193ba15](https://github.com/suxess-it/kubriX/commit/193ba150b634c231b6ad8cf27caec34e06a42689))
* image scans with trivy ([#958](https://github.com/suxess-it/kubriX/issues/958)) ([9aa66db](https://github.com/suxess-it/kubriX/commit/9aa66db6348bebe509a5e2012222cac8cfec92cc))
* list all images used by all platform charts ([#943](https://github.com/suxess-it/kubriX/issues/943)) ([ba70d27](https://github.com/suxess-it/kubriX/commit/ba70d27dfe4166c6c3b974abef00135fa5a7e574))
* make trivy scans via github code scanning optional with github variables ([#968](https://github.com/suxess-it/kubriX/issues/968)) ([2bd976e](https://github.com/suxess-it/kubriX/commit/2bd976e778848d97bb93a60fdd8b4a2bd80e909d))
* run analyses when apps are not synced and healthy after configurable KUBRIX_BOOTSTRAP_MAX_WAIT_TIME ([#840](https://github.com/suxess-it/kubriX/issues/840)) ([ea3538f](https://github.com/suxess-it/kubriX/commit/ea3538f70e3ef9b9d53210e1087dfabac3a5a567))
* run trivy scan pipeline on demand ([#969](https://github.com/suxess-it/kubriX/issues/969)) ([05aa637](https://github.com/suxess-it/kubriX/commit/05aa637234f2543d07508cb630525fce0fd993b2))
* **sync-upstream:** support new commits in from-upstream branch ([#967](https://github.com/suxess-it/kubriX/issues/967)) ([1a122eb](https://github.com/suxess-it/kubriX/commit/1a122eb5ded2bdda083e413bc8701c322118a00b))
* **trivy-scan:** use safir component id without image tag ([#962](https://github.com/suxess-it/kubriX/issues/962)) ([2811e20](https://github.com/suxess-it/kubriX/commit/2811e20c011fdfd7cbf275711cd563317051a391))
* use feat and fix commits also for renovate deps updates ([#939](https://github.com/suxess-it/kubriX/issues/939)) ([d985b61](https://github.com/suxess-it/kubriX/commit/d985b61aa7399c0ab5dbf96ef0995fa0f4fe5111))

### Prime Features (only available with kubriX prime plan)

* **hub-and-spoke**: support "hub and spoke" architecture ([kubriX-prime/285a297](https://github.com/suxess-it/kubriX-prime/commit/285a29717068a242441dee8f14b568fba3328520))
* **hub-and-spoke**: propagate cluster labels to spoke applications ([kubriX-prime/#6](https://github.com/suxess-it/kubriX-prime/issues/6)) ([kubriX-prime/0035ea9](https://github.com/suxess-it/kubriX-prime/commit/0035ea9b75838efc3f1a7d98f8f60804cb9c7eeb))

### Bug Fixes

* add docker datasource for crossplane providers ([#951](https://github.com/suxess-it/kubriX/issues/951)) ([43dcef8](https://github.com/suxess-it/kubriX/commit/43dcef89e08301584bd6dadcb8210f1bc728d4f6))
* add empty values file for diff action ([#944](https://github.com/suxess-it/kubriX/issues/944)) ([0539474](https://github.com/suxess-it/kubriX/commit/05394747a8f6b3d40051952a183ef59de3a5404e))
* add empty values file for diff action ([#945](https://github.com/suxess-it/kubriX/issues/945)) ([965b5e0](https://github.com/suxess-it/kubriX/commit/965b5e0c279f845a287306b4425f4cc65445df76))
* correct release-please optional condition ([#955](https://github.com/suxess-it/kubriX/issues/955)) ([c6c3ca4](https://github.com/suxess-it/kubriX/commit/c6c3ca4ecd0d6e8f686ce35b85bdfa2e69bf958d))
* **deps:** update helm release argo-rollouts to v2.38.1 ([#948](https://github.com/suxess-it/kubriX/issues/948)) ([59cc8aa](https://github.com/suxess-it/kubriX/commit/59cc8aafdd5779dcdc4ebe8c9eebdf6534e58393))
* **diff-action:** only directories are charts ([#946](https://github.com/suxess-it/kubriX/issues/946)) ([ff1ec95](https://github.com/suxess-it/kubriX/commit/ff1ec95ff1bc20e4a0ed9cd520389b623bb9dc58))
* **pipeline:** only commit when changes in image list ([#947](https://github.com/suxess-it/kubriX/issues/947)) ([dd8348c](https://github.com/suxess-it/kubriX/commit/dd8348c30139ca1282f188263b42a0ac1f69c6f8))
* remove scope and add breaking change for major versions ([#950](https://github.com/suxess-it/kubriX/issues/950)) ([ed579ff](https://github.com/suxess-it/kubriX/commit/ed579ff29c99c59612f911719d08ee81afb4a5be))
* split size by byte when file bigger than max size ([169f730](https://github.com/suxess-it/kubriX/commit/169f730c5cff0f5e0d7f848661a3e653093a482c))
* sync upstream with different tokens ([#957](https://github.com/suxess-it/kubriX/issues/957)) ([405e2c8](https://github.com/suxess-it/kubriX/commit/405e2c836b0ce8abbfb3b3c57e46ef51801034d7))
