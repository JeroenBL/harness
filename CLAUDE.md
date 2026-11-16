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
- A new connector gets a branch named `<Name>` in this repo, with its files in `Generated/<Name>`. Claude takes the connector name from the API specification. If the spec does not make it clear, Claude guesses it. Claude never asks the owner for the name.
- A new connector is always based on the template for its type, listed in `typeInputs` in the schema: for `target`, the `target` folder of https://github.com/Tools4everBV/HelloID-Conn-Prov-Target-V2-Template; for `source`, `C:\_Data\connector-shared\templates\HelloID-Conn-Prov-Source-TemplateConnectorName`; for `target-access`, the same Tools4ever V2 `target` template as for `target`, adapted.
- Before building anything, Claude re-checks the report `reports/<Name>-feasibility.md`: it must adhere to the schema `C:\_Data\connector-shared\feasibilitySchema.yaml`, its verdict must be `feasible` or `feasible-with-caveats`, and the owner must have signed it off. If any of the three fails, Claude creates no branch and no folder, writes no code, and says which check failed.
- When the owner tells Claude to build a new connector and the checks above pass, Claude creates the branch `<Name>` and the folder `Generated/<Name>`.
- Claude reads the `type` in the report's YAML to decide which type of connector to build, and puts the template for that type into `Generated/<Name>` (for `target`, fetched from the template repo).
- At the end of the build step, Claude creates a pull request on GitHub for the branch `<Name>`. Its description only points to the README's Remarks section.
- Then Claude develops the connector code in `Generated/<Name>`, directly (not through the connector-gen skill), from the template, the signed-off API research report, the API specification and the baseline documents for the type. The owner signs off the code in the pull request. The owner's colleague reviews it there, on GitHub.
- The API research report is always `reports/<Name>-feasibility.md` at the root of this repo, for example `reports/Example-feasibility.md`.
- The API specification stays outside this repo. The owner gives Claude its path or link in the session. Never add it to the repo.
- `reports/` and `Generated/*/test/` stay local. Git ignores them (see .gitignore). Never force-add them.

## Research: what the report checks
- The pipeline starts with two inputs that the owner provides: the connector type and the API specification. The Azure DevOps ticket is upstream of them and outside the pipeline.
- There are three connector types: `source`, `target` and `target-access`. The owner sets the type for the research, together with the API specification, and it is read first. It decides which baseline documents the research reads and which template the build starts from (see `typeInputs` in the schema). The report records it in the YAML field `type`.
- API research comes first, before any branch or code. Claude reads the API specification, writes `reports/<Name>-feasibility.md`, and the owner signs it off.
- The report starts with a YAML block (target, spec, specSha256, reportDate, verdict, confidence, trial, sections), then has these parts: a verdict (one of the standard labels feasible, feasible-with-caveats, not-feasible, insufficient-information, chosen by the rules in the schema); sources; an API overview (authentication, resources, correlation, constraints); an action table (create, enable, disable, update, delete: status Confirmed, Potential or Not supported, endpoint and method, evidence); a field mapping table (field, label, API field or parts, evidence); a baseline comparison (baseline capability, label, note); and caveats plus an open questions table (number, question, who answers, blocking or non-blocking). The template has the exact layout.
- The report has the same sections for every type. The rows in the action table and the field mapping table depend on the type: Claude takes them from the baseline documents for the type, not from the template's example rows, which are for `target`. The mapping table has the same columns for every type: field, label (Direct, Derivable, Missing, Not applicable), API field or parts, and evidence. For `source` the fields come from `source\helloidPersonSchema.md`, as in the example source report `C:\Temp\ConnectorX\reports\ExampleSource-feasibility.md`. Source and target reports have no extra sections between them. An action not found in the spec gets the status Not supported, with the reason in the evidence column.
- The builder learns the authentication method from the report's API overview.
- Before the owner signs off the report, the owner checks four things: the verdict matches the tables; every baseline field is mapped or has a stated gap; every blocking question names who answers it; and the schema check passed.
- The verdict gates the build. Once the owner has signed off the report: `feasible` and `feasible-with-caveats` let Claude start building (with the caveats in the README's Remarks). `not-feasible` and `insufficient-information` do not: Claude creates no branch and writes no code. For both `not-feasible` and `insufficient-information` the owner decides case by case what to do (for example ask the vendor, redo the report, or stop).
- Claude writes the report from the template `C:\_Data\connector-shared\feasibilityTemplate.md`.
- Before showing a report to the owner, Claude checks it against the schema `C:\_Data\connector-shared\feasibilitySchema.yaml`: the YAML block's fields and values, the `sections` list against the report's headings, and the allowed labels (action status, open-question status, mapping label, baseline comparison label). Claude says if anything fails and does not present a failing report as ready.
- The report does not repeat what the builder already has: the API specification, the template files, the baseline documents and this file.
- The report checks whether the target's API aligns with the baseline:
  - the baseline documents for the connector type, listed in `typeInputs` in the schema (`C:\_Data\connector-shared\source`, `target` or `target-access`)
  - the HelloID target systems documentation: https://docs.helloid.com/en/provisioning/target-systems.html
- The owner gives the path or link of the API specification in the session. For a real connector this is the target's own specification.
- A baseline's own API may be the API under test, to test the pipeline. This is a trial run: the report sets `trial: true`, and Claude runs it without asking whether to. Such a report compares the API with itself, so it says nothing about a real connector.

## Credentials and testing
- Claude tests only against mocked APIs. It may run the debug scripts only when they point at a mock.

## Git in this repo
- The owner makes the first commit on main. Claude does not.
- Branch per task, pull request reviewed before merge.
- One Claude session at a time, in this folder only.
- Claude may push task branches only, never main directly.
- Claude may open and review a pull request. The owner reads the review; Claude merges only after the owner says OK in the session.
- The connector pull request is the exception to Claude's review: Claude creates it but does not review it. The owner's colleague reviews it on GitHub and has access to this repo.
