# HelloID-Conn-Prov-Source-Officient

> [!IMPORTANT]
> This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements.

## Table of contents

- [HelloID-Conn-Prov-Source-Officient](#helloid-conn-prov-source-officient)
  - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Getting started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Connection settings](#connection-settings)
  - [Remarks](#remarks)
  - [Development resources](#development-resources)
    - [API endpoints](#api-endpoints)
    - [API documentation](#api-documentation)
  - [Getting help](#getting-help)
  - [HelloID docs](#helloid-docs)

## Introduction

_HelloID-Conn-Prov-Source-Officient_ is a _Source_ connector. _Officient_ provides a set of REST API's that allow you to programmatically interact with its data. The connector imports persons with their contracts, and departments.

## Getting started

### Prerequisites

- **Access token**:<br>
  An Officient access token with the scopes `basics:read` and `personal.info:read`. The scope `wages:read` is needed as well when the setting _Use wage history for contracts_ is on. The token is created for a client app at `https://app.officient.io/developer`.

### Connection settings

The following settings are required to connect to the API.

| Setting                        | Description                                                                                                                                  | Mandatory |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| BaseUrl                        | The URL to the API. Default: `https://api.officient.io`                                                                                      | Yes       |
| Access token                   | The access token, sent as a bearer token                                                                                                     | Yes       |
| Include archived persons       | Also import archived persons. Default: off                                                                                                   | No        |
| Use wage history for contracts | Build the contracts from the wage history of each person. When off, one contract per person is built from the employment dates. Default: on | No        |
| Toggle debug logging           | Show extra logging. Do not use in production                                                                                                 | No        |

## Remarks

### Authentication
- **Access token only**: The connector sends the configured access token as a bearer token. It does not request or refresh tokens. The Officient documentation does not describe a client-credentials flow or the lifetime of a token created in the developer portal. When the token expires, the import fails with an authorization error and a new token must be configured.

### Rate limit
- **30 calls per 5 seconds**: The connector waits between calls and retries when the API answers HTTP 429. The persons import needs one list call per 30 persons, plus one detail call and (when wage history is used) one wage history call per person. A full import of 1,000 persons therefore takes more than 8 minutes.

### Contracts are built from the wage history
- **No contract resource**: Officient has no employment-contract resource. The `/1.0/contracts` endpoints return signed documents, not employment periods. By default, every wage history period is a contract: the period `id` is the contract `ExternalId`, and the contract type, the dates and the hours per week come from the period.
- **No wage history**: A person without wage history periods gets one contract from the employment dates (`first_employment_date`, `last_employment_date`) of the person. This is also the case for all persons when _Use wage history for contracts_ is off.
- **Salary data is not imported**: Reading the wage history needs the `wages:read` scope, which exposes salary data. The connector copies only the period dates, type and working hours.
- **Open end date**: An empty `end_date` is imported as no end date.

### Team, job title and manager are current values
- The API returns the current team, role and manager of a person, not a history. The same values are put on every contract of the person. Changes of team, role or manager in the past or future are not visible in HelloID.
- Teams are imported as departments. A team has an id and a name only, so departments have no manager and no parent.
- A role has no id or code, so the role name is used as both `Title.Name` and `Title.ExternalId`.

### Persons
- **Name convention**: The values of `last_name_composition` are not documented, so every person gets the naming convention `B`. Change it in the script if your tenant uses partner names.
- **Nick name**: Officient has no nick name. The first name is mapped to `Name.NickName`.
- **Phone**: Officient has one `phone` field without a type. It is mapped to the personal mobile phone.
- **Address**: The home address is imported. Street and house number are in one field (`line_1`) and are not split.
- **Fields that are not imported**: National number, social security number, bank account (IBAN and BIC), emergency contact and salary data are never copied.
- **Custom fields**: Officient custom fields (`custom_fields`) are not imported. Add them to `persons.ps1` and `mapping.json` when needed.
- **Archived persons**: Archived persons are only imported when _Include archived persons_ is on. Persons that are no longer returned are no longer in the source for HelloID.
- **Username**: Officient has no username field, so `Username` is not mapped.
- **Response format**: The connector accepts the API results with or without a `data` wrapper. Field names are taken from the Officient API documentation.

### Email write-back
- The connector does not write the email address back to Officient.

## Development resources

### API endpoints

The following endpoints are used by the connector

| Endpoint                       | Description                                                 |
| ------------------------------ | ----------------------------------------------------------- |
| /1.0/people/list               | Retrieve the persons (30 per page, 0-based `page`)          |
| /1.0/people/{person_id}/detail | Retrieve the details of one person                          |
| /1.0/wages/{person_id}/history | Retrieve the wage history periods of one person (contracts) |
| /1.0/teams/list                | Retrieve the teams (departments)                            |

### API documentation

https://apidocs.officient.io/

## Getting help

> [!TIP]
> _For more information on how to configure a HelloID PowerShell connector, please refer to our [documentation](https://docs.helloid.com/en/provisioning/Source-systems/powershell-v2-Source-systems.html) pages_.

> [!TIP]
>  _If you need help, feel free to ask questions on our [forum](https://forum.helloid.com)_.

## HelloID docs

The official HelloID documentation can be found at: https://docs.helloid.com/
