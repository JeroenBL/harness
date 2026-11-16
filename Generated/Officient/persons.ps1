##################################################
# HelloID-Conn-Prov-Source-Officient-Persons
#
# Version: 1.0.0
##################################################
# Initialize default value's
$config = $configuration | ConvertFrom-Json

# Set debug logging
switch ($($config.IsDebug)) {
    $true { $VerbosePreference = 'Continue' }
    $false { $VerbosePreference = 'SilentlyContinue' }
}

#region functions
function Resolve-OfficientError {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]
        $ErrorObject
    )
    process {
        $httpErrorObj = [PSCustomObject]@{
            ScriptLineNumber = $ErrorObject.InvocationInfo.ScriptLineNumber
            Line             = $ErrorObject.InvocationInfo.Line
            ErrorDetails     = $ErrorObject.Exception.Message
            FriendlyMessage  = $ErrorObject.Exception.Message
        }
        if (-not [string]::IsNullOrEmpty($ErrorObject.ErrorDetails.Message)) {
            $httpErrorObj.ErrorDetails = $ErrorObject.ErrorDetails.Message
        } elseif ($ErrorObject.Exception.GetType().FullName -eq 'System.Net.WebException') {
            if ($null -ne $ErrorObject.Exception.Response) {
                $streamReaderResponse = [System.IO.StreamReader]::new($ErrorObject.Exception.Response.GetResponseStream()).ReadToEnd()
                if (-not [string]::IsNullOrEmpty($streamReaderResponse)) {
                    $httpErrorObj.ErrorDetails = $streamReaderResponse
                }
            }
        }
        try {
            $errorDetailsObject = ($httpErrorObj.ErrorDetails | ConvertFrom-Json)
            # The API returns status_code and reason_phrase on some errors, an empty object on others.
            if ($errorDetailsObject.reason_phrase) {
                $httpErrorObj.FriendlyMessage = "$($errorDetailsObject.status_code) $($errorDetailsObject.reason_phrase)"
            } else {
                $httpErrorObj.FriendlyMessage = $httpErrorObj.ErrorDetails
            }
        } catch {
            $httpErrorObj.FriendlyMessage = "Error: [$($httpErrorObj.ErrorDetails)] [$($_.Exception.Message)]"
        }
        Write-Output $httpErrorObj
    }
}

function Invoke-OfficientRequest {
    # GET with a pause between calls and a retry on HTTP 429. The API allows 30 calls per 5 seconds
    # and answers 429 with an empty body and no retry headers.
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Endpoint
    )
    process {
        $splatParams = @{
            Uri         = "$($config.BaseUrl.TrimEnd('/'))$Endpoint"
            Method      = 'GET'
            Headers     = @{
                Authorization = "Bearer $($config.Token)"
                Accept        = 'application/json; charset=utf-8'
            }
            ContentType = 'application/json; charset=utf-8'
        }
        $maxAttempts = 6
        for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
            Start-Sleep -Milliseconds 200
            try {
                return Invoke-RestMethod @splatParams
            } catch {
                $statusCode = $null
                if ($_.Exception.Response) { $statusCode = [int]$_.Exception.Response.StatusCode }
                if ($statusCode -ne 429 -or $attempt -eq $maxAttempts) { throw }
                Write-Verbose "HTTP 429 on [$Endpoint], waiting 5 seconds (attempt $attempt of $maxAttempts)"
                Start-Sleep -Seconds 5
            }
        }
    }
}

function Get-OfficientData {
    # The API wraps results in 'data'. Return the payload whether or not the wrapper is there.
    param ($Response)
    if ($null -ne $Response -and $Response.PSObject.Properties['data']) { return $Response.data }
    return $Response
}

function ConvertTo-IsoDate {
    param ([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return $null }
    return Get-Date $Value -Format 'o'
}
#endregion

try {
    # The people list is paged (page is 0-based, 30 per page) and holds only a few fields.
    Write-Verbose 'Retrieving the list of persons'
    $includeArchived = if ($config.IncludeArchivedPersons) { '&include_archived=1' } else { '' }
    $personIds = [System.Collections.Generic.List[string]]::new()
    $page = 0
    do {
        $response = Invoke-OfficientRequest -Endpoint "/1.0/people/list?page=$page$includeArchived"
        $pageItems = @(Get-OfficientData $response)
        foreach ($item in $pageItems) { $personIds.Add([string]$item.id) }
        $page++
        # Stop on an empty page, or when the reported total is reached.
        $total = $response.total_record_count
    } while ($pageItems.Count -gt 0 -and ($null -eq $total -or $personIds.Count -lt $total))
    Write-Verbose "Found [$($personIds.Count)] persons"

    Write-Verbose 'Importing raw data in HelloID'
    foreach ($personId in $personIds) {
        $detail = Get-OfficientData (Invoke-OfficientRequest -Endpoint "/1.0/people/$personId/detail")

        # Contracts: Officient has no employment-contract resource. Wage history periods are used as contracts.
        # Only the fields below are copied, so no salary data leaves this script.
        $periods = @()
        if ($config.UseWageHistoryForContracts) {
            $periods = @(Get-OfficientData (Invoke-OfficientRequest -Endpoint "/1.0/wages/$personId/history"))
        }
        if ($periods.Count -eq 0) {
            # Fallback: one contract from the employment dates.
            $periods = @([PSCustomObject]@{
                    id         = $personId
                    start_date = $detail.employment.first_employment_date
                    end_date   = $detail.employment.last_employment_date
                })
        }

        $contracts = foreach ($period in $periods) {
            $minutes = $period.weekly_time_engagement_minutes
            $hoursPerWeek = $null
            if ($minutes) {
                $hoursPerWeek = [math]::Round(($minutes.PSObject.Properties.Value | Measure-Object -Sum).Sum / 60, 2)
            }
            @{
                SequenceNumber = [string]$period.id
                StartDate      = ConvertTo-IsoDate $period.start_date
                EndDate        = ConvertTo-IsoDate $period.end_date # an open end is an empty string in the API
                TypeCode       = $period.custom_payroll_data.contract_type
                TypeName       = $period.type
                HoursPerWeek   = $hoursPerWeek
                # Team, role and manager are current values only. The API has no history per period.
                DepartmentCode = [string]$detail.team.id
                DepartmentName = $detail.team.name
                TitleName      = $detail.current_role.name
                TitleCode      = $detail.current_role.name # the role has no id or code
                ManagerId      = [string]$detail.current_reports_to.person_id
            }
        }

        $person = @{
            ExternalId              = [string]$detail.id
            DisplayName             = "$($detail.first_name) $($detail.last_name)".Trim()
            FirstName               = $detail.first_name
            LastName                = $detail.last_name
            Initials                = $detail.name_parts.initials
            LastNamePrefix          = $detail.name_parts.insertion
            LastNamePartner         = $detail.name_parts.last_name_partner
            LastNamePartnerPrefix   = $detail.name_parts.insertion_partner
            Convention              = 'B' # last_name_composition values are not documented
            Email                   = $detail.email
            PersonalEmail           = $detail.personal_email
            Phone                   = $detail.phone
            Street                  = $detail.address.line_1
            StreetExt               = $detail.address.line_2
            PostalCode              = $detail.address.zipcode
            City                    = $detail.address.city
            Country                 = $detail.address.country_code
            Gender                  = $detail.gender
            BirthDate               = ConvertTo-IsoDate $detail.birthdate
            BirthPlace              = $detail.birthplace
            MaritalStatus           = $detail.civil_state
            Contracts               = @($contracts)
        }

        Write-Output $person | ConvertTo-Json -Depth 10
    }
} catch {
    $ex = $PSItem
    if ($($ex.Exception.GetType().FullName -eq 'Microsoft.PowerShell.Commands.HttpResponseException') -or
        $($ex.Exception.GetType().FullName -eq 'System.Net.WebException')) {
        $errorObj = Resolve-OfficientError -ErrorObject $ex
        Write-Verbose "Could not import Officient persons. Error at Line '$($errorObj.ScriptLineNumber)': $($errorObj.Line). Error: $($errorObj.ErrorDetails)"
        Write-Error "Could not import Officient persons. Error: $($errorObj.FriendlyMessage)"
    } else {
        Write-Verbose "Could not import Officient persons. Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"
        Write-Error "Could not import Officient persons. Error: $($ex.Exception.Message)"
    }
}
