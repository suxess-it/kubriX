# Use Markdown Any Decision Records

* Status: accepted
* Deciders: sX CNP oss Team
* Date: 2023-05-09

## Context and Problem Statement

We want to record any decisions made in this project independent whether decisions concern the architecture ("architectural decision record"), the code, or other fields.
Which format and structure should these records follow?

## Considered Options

* [MADR](https://adr.github.io/madr/) 3.* / 2.* – The Markdown Any Decision Records
* [Michael Nygard's template](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions) – The first incarnation of the term "ADR"
* [Joel Parker Henderson](https://github.com/joelparkerhenderson/architecture-decision-record) – Github
* [Sustainable Architectural Decisions](https://www.infoq.com/articles/sustainable-architectural-design-decisions) – The Y-Statements
* Formless – No conventions for file format and structure
* Target Repo, Backstage Repo or on its own?
* Several ADRs - per each Entity
* Language of Docs
* Backstage integration possible?

## Decision Outcome

Chosen option: "MADR v3", because

* Implicit assumptions should be made explicit.
  Design documentation is important to enable people understanding the decisions later on.
* MADR allows for structured capturing of any decision.
* The MADR format is lean and fits our development style.
* It is supported out of the box by Backstage [ADR Plugin](https://github.com/backstage/backstage/tree/master/plugins/adr)
* The MADR structure is comprehensible and facilitates usage & maintenance.
* We want to have multiple ADR repos for several entities
* [Template](https://github.com/joelparkerhenderson/architecture-decision-record/blob/main/templates/decision-record-template-madr/index.md) – Github
