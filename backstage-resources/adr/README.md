# Architectural Decisions

## What are architectural decisions?

Architectural decisions are high-level technical decisions that affect most stakeholders, in particular sX CNP developers, administrators and users.
A non-exhaustive list of architectural decisions is as follows:

* adding or removing tools;
* adding or removing components;
* changing what component talks to what other component;
* major (in the [SemVer](https://semver.org/) sense) component upgrades.

Architectural decisions should be taken as directions to follow for future development and not issues to be fixed immediately.

## What triggers an architectural decision?

An architectural decision generally starts with one of the following:

* A new features was requested by product management.
* An improvement was requested by engineering management.
* A new risk was discovered, usually by the architect, but also by any stakeholder.
* A new technology was discovered, that may help with a new feature, an improvement or to mitigate a risk.

## How are architectural decisions captured?

Architectural decisions are captured via [Architectural Decision Records](#adrs) or the [tech radar](../tech-radar/index.html).
Both are stored in Git, hence a decision log is also captured as part of the Git commit messages.

## How are architectural decisions taken?

Architectural decisions need to mitigate the following information security risks:

* a component might not fulfill advertised expectations;
* a component might be abandoned;
* a component might change direction and deviate from expectations;
* a component might require a lot of (initial or ongoing) training;
* a component might not take security seriously;
* a component might change its license, prohibiting its reuse or making its use expensive.

The sX CNP architect is overall responsible for this risk.

## CNP ADRs:

Add ADR to Entity - adapt catalog-info.yaml:
```yaml
  annotations:
    backstage.io/adr-location: <RELATIVE_PATH_TO_ADR_FILES_DIR>
```

How to add ADR to sX CNP:
* add ADR - XXXX-<some-name>.md
* add new ADR to List below


This log lists the architectural decisions for sX CNP.

* [ADR-0000](0000-use-madr.md) - Use Markdown Any Decision Records
