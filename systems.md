# Systems I use for this project

Answers as given in the interviews. Nothing here was added by the interviewer.

## Where work happens

- **VS Code**: where I write code.
- **PowerShell**: the language I write in.
- **Azure DevOps**: where requests to build a connector arrive. Upstream of the pipeline.
- **Email**: how I ask the vendor or customer about unclear API behaviour.

## Where records live

- **Azure DevOps**: the request ticket, and sometimes the answer to a vendor or customer question.
- **GitHub (the `harness` repo)**: the working code on the branch `<Name>`, and the pull request with its review comments.
- **My mailbox**: the questions to the vendor or customer, and most of their answers.
- **The `harness` repo** (`C:\_Data\Github\jblaauw\harness`): the toolset that develops the connector code using Claude. It is not a connector repo and not where published connectors go. Earlier I called it "the GitHub repo where finished work ends up"; the corrected answer is this one.
- **The `reports` folder of the `harness` repo** (`C:\_Data\Github\jblaauw\harness\reports`): the API research report, as `<Name>-feasibility.md`, for example `reports\Example-feasibility.md`. It stays on my machine and is not pushed anywhere.
- **The API specification** (JSON, YAML, Word or PDF): it stays wherever I keep it, outside this repo. I give Claude the path or link in the session. Nothing is added to the repo.
- **The connector folder** (`Generated\<Name>` inside the `harness` repo, one folder per connector): the connector's files, including its `test` folder.
- **KeePassXC (password manager)**: the credentials and the connection settings (API URL, tenant and the like) for testing.
- **The mock of the API**, when I build one: built and kept locally. It can live anywhere, depending on how it is created. It is not part of a fixed cycle and has no predefined system or folder.
- **`C:\_Data\connector-shared`**: the best-practices markdown file. On my machine only.
- **GitHub**: the published connector only. After review and OK, I publish by hand: I create a repo and add the files. The repo name is built from the connector name: a connector called `ACME` gets the repo `HelloID-Conn-Prov-Target-ACME`.

## Where I start from (source, not a record of my work)

- **GitHub repo `Tools4everBV/HelloID-Conn-Prov-Target-V2-Template`**: new connectors are based on its files.
  https://github.com/Tools4everBV/HelloID-Conn-Prov-Target-V2-Template

## Workflow, request to result

1. Upstream of the pipeline: a request to build a connector for a customer arrives in Azure DevOps, and I take the API specification from the ticket. The pipeline for Claude starts when I provide that specification (step 2).
2. Claude reads the API specification and writes a report: capabilities, caveats, which of create/enable/disable/update/delete are supported, and whether the API aligns with the baseline documents for the connector type and the HelloID target systems documentation. I sign off the report. I run a connection test. If the API can't be reached, I build a mock.
3. If the documentation is unclear, I email the vendor or customer. Some questions block.
4. Claude develops the code in `Generated\<Name>` from the template. At the end of the build step, Claude creates a pull request on GitHub.
5. I test against production if available, else the vendor's test environment, else a mock.
6. A colleague reviews in the pull request on GitHub, with code comments.
7. After OK, I publish to GitHub by creating a repo and adding the files.

### Where it waits or goes backwards

- A blocking question stops work on that connector, or I make an educated guess and fix any gap in the code later. A wrong guess shows up in my own testing or when the answer arrives.
- Testing depends on which environment is available.
- Review comments can send me back to the code.

## What "the code" is

The files in the template's `target` folder, copied and changed per customer:
`create.ps1`, `update.ps1`, `enable.ps1`, `disable.ps1`, `delete.ps1`, `import.ps1`, `fieldMapping.json`, `configuration.json`, `README.md`, `CHANGELOG.md`, `.gitignore`, and the folders `.github`, `permissions`, `resources` and `test`.
https://github.com/Tools4everBV/HelloID-Conn-Prov-Target-V2-Template/tree/main/target
The `test` folder is not published to GitHub. It stays local, in the connector folder on my machine. It holds debug scripts that use the KeePassXC CLI to retrieve the connection settings, and an `actionContext.json`. I use them to test the individual scripts (create, delete and so on).

## Handoffs: what is passed on, what uses it, where it lives

| Handoff | Passed on | Used by | Lives in |
|---|---|---|---|
| 1. Upstream, outside the pipeline: ticket to API specification | The API specification (a URL, or a JSON, YAML, PDF or Word file), what the customer wants. The customer's wishes don't matter for development and are adjusted as the last step. | Claude's API research | Azure DevOps ticket |
| 2. Research to development | The report Claude writes from the API specification (capabilities, caveats, supported actions), signed off by me. | Writing the code | `harness\reports\<Name>-feasibility.md`, my machine only. The vendor and customer emails stay in my mailbox. |
| 3. Development to testing | The code, the credentials, the connection settings, and a mock if needed (built from the API). | Testing | Code on the branch in the harness repo on GitHub. Credentials and connection settings in KeePassXC. Mock on my machine. |
| 4. Testing to review | The code in a pull request, and sometimes caveats noted during development. | The colleague reviewing | Pull request on GitHub. Caveats always go in the README, in the section called Remarks. The pull request description only points to it. |
| 5. Approved review to publishing | Everything in the connector folder except the `test` folder, added by hand to a new repo. That includes the scripts, the README and the CHANGELOG. | The published connector | GitHub repo |

Nothing was named as existing only in my head. The vendor and customer answers are the closest case: they start in my mailbox, and reach the code only through what I tell Claude.

## Decisions to simplify

- Caveats always go in the README's Remarks section. The pull request description only points to it. Preserved: Remarks stays in the README, and because the README is published to GitHub, everything in it must be fit for publication.

## Who signs off each artifact

- **API research report**: I sign off. Claude writes it from the API specification, and I approve it before the connector is built from it.
- **Connector code** (scripts, `fieldMapping.json`, `configuration.json`): I sign off. Claude may write it, and the pull request is my sign-off. Nothing is signed off before the pull request exists.
- **README (including Remarks) and CHANGELOG**: I sign off. Claude may write them, and the pull request is my sign-off, the same way.
- **`test` folder** (debug scripts, `actionContext.json`): Claude may produce and decide. I use them without a separate approval. Claude may run the debug scripts only when they point at a mocked API, never at a real system.
- **Mock of the API**: Claude may produce and decide. I test against it without a separate approval.
- **Emails to the vendor or customer**: I sign off. Claude may draft a question, and I approve it before I send it myself.
- **GitHub publication** (repo name and the set of files): I produce it myself. Claude doesn't prepare or decide it.
- **Best-practices file** (`C:\_Data\connector-shared`): I produce it myself. Claude doesn't change it.
- **Pull request on GitHub** (creating it and its description): Claude creates it at the end of the build step. The description only points to the README's Remarks section.
- **Credentials and connection settings in KeePassXC**: Claude may never use the CLI. When Claude tests, it only uses mocked APIs.

## Git practice in the `harness` repo

- Who works in it: me, with Claude, one session at a time.
- Existing practice: a branch per task, and a pull request that is reviewed before merge.
- Decision, parallel Claude sessions: I work in this folder only, with a branch per task, and run one Claude session at a time. I chose this over separate clones and worktrees. A branch switch in one session changes the files under any other, so a second session at the same time is not safe.
- Decision, research: what the API can do is in the API specification, which comes as JSON, YAML, a Word document or a PDF. Claude reads the specification and writes a report of what the API can do. I sign off the report, and the connector is built from it: research the API, then the report, then build the connector.
- Decision, what the research checks: the report checks whether the target's API aligns with two baselines, the baseline documents for the connector type (see "Connector types" below) and the HelloID target systems documentation (https://docs.helloid.com/en/provisioning/target-systems.html). I give Claude the API specification in the session. For a real connector that is the target's own specification. A baseline's own API may also be the API under test, to test the pipeline: that is a trial run with `trial: true`, which Claude runs without asking. Such a report compares the API with itself, so it says nothing about a real connector.
- Decision, the name `<Name>`: Claude takes the connector name from the API specification. If the spec does not make it clear, Claude guesses it. Claude never asks me for the name.
- Decision, where a new connector lives: a new connector gets its own branch `<Name>` in this repo. Its files live on that branch, in a new folder `Generated\<Name>` inside the `harness` repo (for example `Generated\Example`).
- Decision, first commit: I make the first commit on `main` myself. Claude does not.
- Decision, precondition for building: before anything is built, the report must adhere to the schema, its verdict must be `feasible` or `feasible-with-caveats`, and I must have signed it off. Claude re-checks all three before it creates the branch. If any fails, there is no branch, no folder and no code, and Claude says which check failed.
- Decision, creating the connector folder and branch: when I tell Claude to build a new connector, Claude creates the branch `<Name>` and the folder `Generated\<Name>`.
- Decision, template files: Claude fetches the template's `target` folder from the template repo into `Generated\<Name>`.
- Decision, code route: Claude writes the code directly, not through the connector-gen skill. It builds from the template and the signed-off report.
- Decision, developing the code: after creating the folder, Claude develops the connector code in `Generated\<Name>`, from the template and the signed-off report. I sign off the code in the pull request.
- Decision, template: a new connector is always based on the Tools4ever V2 template (the `target` folder of the template repo listed under "Where I start from").
- Decision, keeping files local: the research report in `harness\reports` and the `test` folder inside `Generated\<Name>` stay local because git ignores them. They are never committed or pushed.
- Decision, the review pull request: it is a GitHub pull request, not an Azure DevOps one. Claude creates it at the end of the build step.
- Decision, sign-off and review of the connector pull request: the pull request is my sign-off. My colleague reviews it on GitHub, and has access to the `harness` repo. Claude creates this pull request but does not review it. The line about Claude's review applies to other `harness` changes only.
- Decision, Claude and pull requests: Claude may open and review a pull request. I read its review, and Claude merges only after I explicitly say OK in the session.
- Decision, pushing: Claude may push task branches only. Changes reach `main` through a merged pull request, not a direct push.

## Connector types

- There are three connector types: `source`, `target` and `target-access`. I set the type for the research, together with the API specification, and it is read first. It is recorded in the report's YAML field `type`. The build step reads that field to decide which type of connector to build. The schema `C:\_Data\connector-shared\feasibilitySchema.yaml` has the `type` field and a `typeInputs` list.
- Per type, from the folders I added to `C:\_Data\connector-shared` (the mapping follows the folder names and is not yet confirmed by me):
  - `source`: baseline documents `source\baselineSource.md` and `source\helloidPersonSchema.md`. Template: `templates\HelloID-Conn-Prov-Source-TemplateConnectorName`, a different PowerShell template with `persons.ps1`, `departments.ps1`, `configuration.json` and `mapping.json`.
  - `target`: baseline document `target\baselineUsers.md` (moved there from the folder root). Template: the `target` folder of the Tools4ever V2 template on GitHub.
  - `target-access`: baseline document `target-access\baselineAccess.md`. Template: the Tools4ever V2 `target` template, the same as for `target`, adapted.
- The report has the same sections for every type. The rows in the action table and the field mapping table depend on the type, taken from the baseline documents for the type.
- A source has no `fieldMapping.json`, but the report still has a mapping table. The mapping table has the same columns for every type: field, label, API field or parts, and evidence. For `source` the fields come from `source\helloidPersonSchema.md`, as in the example source report `C:\Temp\ConnectorX\reports\ExampleSource-feasibility.md`.
- Standard labels taken over from the example source report: mapping labels Direct, Derivable, Missing, Not applicable; baseline comparison labels Equivalent, Different shape, Unclear. The schema has all of these. Source and target reports have the same sections, so there is no numbered "Checks" list for either type. The action status stays Confirmed, Potential or Not supported. An action "not found in the spec", as the source example calls it, is written as Not supported, with the reason in the evidence column.
- Trial run on the example API: the connector name is `DemoTarget`.

## Upstream of the pipeline: the Azure DevOps ticket

- The pipeline for Claude does not start with Azure DevOps. It starts with two inputs that I provide: the connector type and the API specification. The ticket is how I get that specification, and it is outside the pipeline. The first artifact in Claude's pipeline is the API specification.

- Reader: me.
- What I must be able to do with it: find the API specification, and start the research in a session.
- What I already know when I open it: HelloID and the baseline. The ticket doesn't need to explain them. I don't assume I know the customer, the target system or where its specification lives.
- What it must contain: the API specification, as either a URL to it or the file itself (JSON, YAML, PDF or Word), and what the customer wants. The ticket is the only route to the API specification.
- Not required in the ticket: the customer name, the connector name.
- Without an API specification we cannot build the connector. The specification is vital. A ticket without one blocks the work.
- Shape: free text, as it arrives. The requester writes it however they like, and I find the link and the request in the text myself.

## The second artifact: the API research report

- Readers: me, to sign it off, and a fresh Claude session, to build the connector. The session starts with no memory of the research.
- What the builder must be able to do from the report alone: call the right endpoint per action, map fields to the baseline, and handle the caveats. The builder learns the authentication method from the report's API overview.
- What I check before I sign off the report: the verdict matches the tables; every baseline field is mapped or has a stated gap; every blocking question names who answers it; and the schema check passed.
- The verdict gates the build. Once I have signed off the report: `feasible` and `feasible-with-caveats` let Claude start building, with the caveats in the README's Remarks. `not-feasible` and `insufficient-information` do not: Claude creates no branch and writes no code. For both `not-feasible` and `insufficient-information` I decide case by case what to do (for example ask the vendor, redo the report, or stop).
- What the builder already has besides the report: the API specification itself, the template files, the baseline documents for the type and `CLAUDE.md`. The report therefore does not repeat them.
- The report starts with a YAML block: target, spec, specSha256, reportDate, verdict, confidence, trial, sections. `sections` lists the sections the report contains.
- New reports must adhere to a YAML schema, `C:\_Data\connector-shared\feasibilitySchema.yaml`, on my machine only. Claude checks each report against it before showing it to me.
- Parts of the report: a verdict, sources, an API overview (authentication, resources, correlation, constraints), an action table (create, enable, disable, update, delete, each with status Confirmed, Potential or Not supported, endpoint and method, and evidence), a field mapping table, a baseline comparison, and caveats plus an open questions table (number, question, who answers, blocking or non-blocking). The `C:\_Data\connector-shared\feasibilityTemplate.md` template has the exact layout. Taken over from the example report `C:\Temp\reports\ExampleTarget-feasibility.md`.
- The verdict uses standard labels, taken from the example report and the connector-scout skill's schema: `feasible`, `feasible-with-caveats`, `not-feasible`, `insufficient-information`. The schema file defines when each applies, and the confidence levels high, medium and low.
- The report is written from a template: `C:\_Data\connector-shared\feasibilityTemplate.md`, on my machine only. The first run on the example API (`Basic-EXAMPLE-Target-API`, the same API as the baseline) is a trial run, so its report compares the baseline with itself and says nothing about a real target.

## Timing and the end of the workflow

- Waiting for vendor or customer answers and for test environment access: it depends, from days to weeks.
- Review usually sends the work back once. What the comments are usually about was not stated.
- Publishing to GitHub is the last step. Nothing follows it.

## Open questions (not answered yet)

- None.
