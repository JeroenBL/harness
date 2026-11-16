# Harness agreement

Decisions made by the owner. Workflow, systems and handoffs are in systems.md.

## Who signs off each artifact
- connector-scout report: Claude may produce and decide.
- Connector code (scripts, fieldMapping.json, configuration.json): owner signs off. Claude may write it; the owner approves before it goes into the pull request.
- README (including Remarks) and CHANGELOG: owner signs off, same way.
- Caveats always go in the README's Remarks section. Everything in the README is published, so it must be fit for publication.
- test folder (debug scripts, actionContext.json): Claude may produce and decide.
- Mock of the API: Claude may produce and decide.
- Emails to the vendor or customer: Claude may draft; the owner approves and sends.
- GitHub publication (repo name, set of files), the best-practices file in C:\_Data\connector-shared, and the pull request in Azure DevOps: the owner produces them. Claude does not.

## Where a new connector lives
- A new connector gets a branch named `<Name>` in this repo, with its files in `Generated/<Name>`.
- A new connector is always based on the Tools4ever V2 template: the `target` folder of https://github.com/Tools4everBV/HelloID-Conn-Prov-Target-V2-Template.
- When the owner tells Claude to build a new connector based on the scout report, Claude creates the branch `<Name>` and the folder `Generated/<Name>`.
- Claude fetches the template's `target` folder from the template repo into `Generated/<Name>`.
- Then Claude develops the connector code in `Generated/<Name>`, directly from the markdown scout report and the template (not through the connector-gen skill). The owner signs off the code before it goes into the pull request.
- The connector-scout report is always `reports/<Name>-feasibility.md` at the root of this repo, for example `reports/Example-feasibility.md`. The branch name is the part before `-feasibility.md`.
- `reports/` and `Generated/*/test/` stay local. Git ignores them (see .gitignore). Never force-add them.

## Credentials and testing
- Claude never uses the KeePassXC CLI.
- Claude tests only against mocked APIs. It may run the debug scripts only when they point at a mock.

## Git in this repo
- The owner makes the first commit on main. Claude does not.
- Branch per task, pull request reviewed before merge.
- One Claude session at a time, in this folder only.
- Claude may push task branches only, never main directly.
- Claude may open and review a pull request. The owner reads the review; Claude merges only after the owner says OK in the session.
