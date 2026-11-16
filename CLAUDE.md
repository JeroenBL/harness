# Harness agreement

Decisions made by the owner. Workflow, systems and handoffs are in systems.md.

## Who signs off each artifact
- API research report: owner signs off. Claude writes it from the API specification (JSON, YAML, Word or PDF); the owner approves it before the connector is built from it.
- Connector code (scripts, fieldMapping.json, configuration.json): owner signs off. Claude may write it; the pull request is the owner's sign-off. Nothing is signed off before the pull request exists.
- README (including Remarks) and CHANGELOG: owner signs off, same way.
- Caveats always go in the README's Remarks section. Everything in the README is published, so it must be fit for publication.
- test folder (debug scripts, actionContext.json): Claude may produce and decide.
- Mock of the API: Claude may produce and decide.
- Emails to the vendor or customer: Claude may draft; the owner approves and sends.
- GitHub publication (repo name, set of files) and the best-practices file in C:\_Data\connector-shared: the owner produces them. Claude does not.
- The GitHub pull request for a new connector: Claude creates it at the end of the build step.

## Where a new connector lives
- A new connector gets a branch named `<Name>` in this repo, with its files in `Generated/<Name>`. Claude takes the connector name from the API specification and proposes it. The owner confirms it before it is used for the report, the branch and the folder.
- A new connector is always based on the Tools4ever V2 template: the `target` folder of https://github.com/Tools4everBV/HelloID-Conn-Prov-Target-V2-Template.
- When the owner tells Claude to build a new connector, Claude creates the branch `<Name>` and the folder `Generated/<Name>`.
- Claude fetches the template's `target` folder from the template repo into `Generated/<Name>`.
- At the end of the build step, Claude creates a pull request on GitHub for the branch `<Name>`. Its description only points to the README's Remarks section.
- Then Claude develops the connector code in `Generated/<Name>`, directly (not through the connector-gen skill), from the template, the signed-off API research report, the API specification and the baseline users file. The owner signs off the code in the pull request. The owner's colleague reviews it there, on GitHub.
- The API research report is always `reports/<Name>-feasibility.md` at the root of this repo, for example `reports/Example-feasibility.md`.
- The API specification stays outside this repo. The owner gives Claude its path or link in the session. Never add it to the repo.
- `reports/` and `Generated/*/test/` stay local. Git ignores them (see .gitignore). Never force-add them.

## Research: what the report checks
- The pipeline starts with an API specification that the owner provides. The Azure DevOps ticket is upstream of it and outside the pipeline.
- API research comes first, before any branch or code. Claude reads the API specification, writes `reports/<Name>-feasibility.md`, and the owner signs it off.
- The report starts with a YAML block (target, spec, specSha256, reportDate, verdict, confidence, trial), then has these parts: a verdict (fits, fits with gaps, or does not fit); sources; an API overview (authentication, resources, correlation, constraints); an action table (create, enable, disable, update, delete: status Confirmed, Potential or Not supported, endpoint and method, evidence); a field mapping table (baseline field, API field, gap or transformation); a baseline comparison; and caveats plus an open questions table (number, question, who answers, blocking or non-blocking). The template has the exact layout.
- The builder learns the authentication method from the report's API overview.
- Before the owner signs off the report, the owner checks four things: the verdict matches the tables; every baseline field is mapped or has a stated gap; every blocking question names who answers it; and the schema check passed.
- After a "does not fit" verdict, the owner decides case by case: go on, ask the vendor, or stop. Claude does not continue to a branch or code on its own.
- Claude writes the report from the template `C:\_Data\connector-shared\feasibilityTemplate.md`.
- Before showing a report to the owner, Claude checks it against the schema `C:\_Data\connector-shared\feasibilitySchema.yaml`: the YAML block's fields and values, the `sections` list against the report's headings, and the allowed action and open-question statuses. Claude says if anything fails and does not present a failing report as ready.
- The report does not repeat what the builder already has: the API specification, the template files, the baseline users file and this file.
- The report checks whether the target's API aligns with the baseline:
  - the baseline users file: C:\_Data\connector-shared\baselineUsers.md
  - the HelloID target systems documentation: https://docs.helloid.com/en/provisioning/target-systems.html
- The baseline is never the API under test. The owner gives the path or link of the target's own specification in the session.

## Credentials and testing
- Claude never uses the KeePassXC CLI.
- Claude tests only against mocked APIs. It may run the debug scripts only when they point at a mock.

## Git in this repo
- The owner makes the first commit on main. Claude does not.
- Branch per task, pull request reviewed before merge.
- One Claude session at a time, in this folder only.
- Claude may push task branches only, never main directly.
- Claude may open and review a pull request. The owner reads the review; Claude merges only after the owner says OK in the session.
- The connector pull request is the exception to Claude's review: Claude creates it but does not review it. The owner's colleague reviews it on GitHub and has access to this repo.
