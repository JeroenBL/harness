# Systems I use for this project

Answers as given in the interviews. Nothing here was added by the interviewer.

## Where work happens

- **VS Code**: where I write code.
- **PowerShell**: the language I write in.
- **connector-scout skill**: finds out what a target system's API supports.
- **Azure DevOps**: where I develop (the repo I push to) and where the colleague reviews. Requests to build a connector also arrive here.
- **Email**: how I ask the vendor or customer about unclear API behaviour.

## Where records live

- **Azure DevOps**: the request ticket, sometimes the answer to a vendor or customer question, the working code, and the review comments in the pull request.
- **My mailbox**: the questions to the vendor or customer, and most of their answers.
- **The `harness` repo** (`C:\_Data\Github\jblaauw\harness`): the toolset that develops the connector code using Claude. It is not a connector repo and not where published connectors go. Earlier I called it "the GitHub repo where finished work ends up"; the corrected answer is this one.
- **The `reports` folder of the `harness` repo** (`C:\_Data\Github\jblaauw\harness\reports`, always here): the connector-scout markdown report, as `<Name>-feasibility.md`, for example `reports\Example-feasibility.md`. It stays on my machine and is not pushed anywhere. Decisions come from this report: what the API can do decides whether and how we build a connector.
- **The connector folder** (`Generated\<Name>` inside the `harness` repo, one folder per connector): the connector's files, including its `test` folder.
- **KeePassXC (password manager)**: the credentials and the connection settings (API URL, tenant and the like) for testing.
- **The mock of the API**, when I build one: built and kept locally. It can live anywhere, depending on how it is created. It is not part of a fixed cycle and has no predefined system or folder.
- **`C:\_Data\connector-shared`**: the best-practices markdown file. On my machine only.
- **GitHub**: the published connector only. After review and OK, I publish by hand: I create a repo and add the files. The repo name is built from the connector name: a connector called `ACME` gets the repo `HelloID-Conn-Prov-Target-ACME`.

## Where I start from (source, not a record of my work)

- **GitHub repo `Tools4everBV/HelloID-Conn-Prov-Target-V2-Template`**: new connectors are based on its files.
  https://github.com/Tools4everBV/HelloID-Conn-Prov-Target-V2-Template

## Workflow, request to result

1. A request to build a connector for a customer arrives in Azure DevOps.
2. I read the API documentation and run connector-scout: capabilities, caveats, which of create/enable/disable/update/delete are supported. I run a connection test. If the API can't be reached, I build a mock.
3. If the documentation is unclear, I email the vendor or customer. Some questions block.
4. I develop the code in VS Code from the template, in Azure DevOps.
5. I test against production if available, else the vendor's test environment, else a mock.
6. A colleague reviews in a pull request in Azure DevOps, with code comments.
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
| 1. Request to API research | Customer name, link to the API documentation, what the customer wants. The customer's wishes don't matter for development and are adjusted as the last step. | Research with connector-scout | Azure DevOps ticket |
| 2. Research to development | The full connector-scout report (what the API can do, supported endpoints). Vendor or customer answers are corrected in the report by hand. | Writing the code | `harness\reports\<Name>-feasibility.md`, my machine only. The original emails stay in my mailbox. |
| 3. Development to testing | The code, the credentials, the connection settings, and a mock if needed (built from the API). | Testing | Code in Azure DevOps. Credentials and connection settings in KeePassXC. Mock on my machine. |
| 4. Testing to review | The code in a pull request, and sometimes caveats noted during development. | The colleague reviewing | Pull request in Azure DevOps. Caveats always go in the README, in the section called Remarks. The pull request description only points to it. |
| 5. Approved review to publishing | Everything in the connector folder except the `test` folder, added by hand to a new repo. That includes the scripts, the README and the CHANGELOG. | The published connector | GitHub repo |

Nothing was named as existing only in my head. The vendor and customer answers are the closest case: they start in my mailbox and reach the report only because I edit it by hand.

## Decisions to simplify

- Caveats always go in the README's Remarks section. The pull request description only points to it. Preserved: Remarks stays in the README, and because the README is published to GitHub, everything in it must be fit for publication.

## Who signs off each artifact

- **connector-scout report**: Claude may produce and decide. Development can start without my approval.
- **Connector code** (scripts, `fieldMapping.json`, `configuration.json`): I sign off. Claude may write it, and I approve it before it goes into the pull request.
- **README (including Remarks) and CHANGELOG**: I sign off. Claude may write them, and I approve them before they go into the pull request.
- **`test` folder** (debug scripts, `actionContext.json`): Claude may produce and decide. I use them without a separate approval. Claude may run the debug scripts only when they point at a mocked API, never at a real system.
- **Mock of the API**: Claude may produce and decide. I test against it without a separate approval.
- **Emails to the vendor or customer**: I sign off. Claude may draft a question, and I approve it before I send it myself.
- **GitHub publication** (repo name and the set of files): I produce it myself. Claude doesn't prepare or decide it.
- **Best-practices file** (`C:\_Data\connector-shared`): I produce it myself. Claude doesn't change it.
- **Pull request in Azure DevOps** (creating it and its description): I produce it myself. Claude doesn't write it.
- **Credentials and connection settings in KeePassXC**: Claude may never use the CLI. When Claude tests, it only uses mocked APIs.

## Git practice in the `harness` repo

- Who works in it: me, with Claude, one session at a time.
- Existing practice: a branch per task, and a pull request that is reviewed before merge.
- Decision, parallel Claude sessions: I work in this folder only, with a branch per task, and run one Claude session at a time. I chose this over separate clones and worktrees. A branch switch in one session changes the files under any other, so a second session at the same time is not safe.
- Decision, branch name for a new connector: I create a new branch in this repo, named after the scout report. The report `Example-Feasibility.md` gives the branch `Example`. The connector's files live on that branch, in a new folder `Generated\<Name>` inside the `harness` repo (here `Generated\Example`).
- Decision, first commit: I make the first commit on `main` myself. Claude does not.
- Decision, creating the connector folder and branch: when I tell Claude to build a new connector based on the scout report, Claude creates the branch `<Name>` and the folder `Generated\<Name>`.
- Decision, template files: Claude fetches the template's `target` folder from the template repo into `Generated\<Name>`.
- Decision, code route: Claude writes the code directly from the markdown scout report and the template, not through the connector-gen skill.
- Decision, developing the code: after creating the folder, Claude develops the connector code in `Generated\<Name>`, from the template and the scout report. I sign off the code before it goes into the pull request.
- Decision, template: a new connector is always based on the Tools4ever V2 template (the `target` folder of the template repo listed under "Where I start from").
- Decision, keeping files local: the scout report in `harness\reports` and the `test` folder inside `Generated\<Name>` stay local because git ignores them. They are never committed or pushed.
- Decision, Claude and pull requests: Claude may open and review a pull request. I read its review, and Claude merges only after I explicitly say OK in the session.
- Decision, pushing: Claude may push task branches only. Changes reach `main` through a merged pull request, not a direct push.

## Timing and the end of the workflow

- Waiting for vendor or customer answers and for test environment access: it depends, from days to weeks.
- Review usually sends the work back once. What the comments are usually about was not stated.
- Publishing to GitHub is the last step. Nothing follows it.

## Open questions (not answered yet)

- None.
