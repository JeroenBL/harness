##################################################
# HelloID-Conn-Prov-Source-Officient-Departments
#
# Version: 1.0.0
##################################################
# Initialize default value's
$config = $Configuration | ConvertFrom-Json

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
#endregion

try {
    # Officient teams are used as departments. The API returns id and name only: no manager, no parent.
    Write-Verbose 'Retrieving the list of teams'
    $teams = @(Get-OfficientData (Invoke-OfficientRequest -Endpoint '/1.0/teams/list'))
    Write-Verbose "Found [$($teams.Count)] teams"

    Write-Verbose 'Importing raw data in HelloID'
    foreach ($team in $teams) {
        $department = @{
            ExternalId  = [string]$team.id
            DisplayName = $team.name
            Name        = $team.name
        }
        Write-Output $department | ConvertTo-Json -Depth 10
    }
} catch {
    $ex = $PSItem
    if ($($ex.Exception.GetType().FullName -eq 'Microsoft.PowerShell.Commands.HttpResponseException') -or
        $($ex.Exception.GetType().FullName -eq 'System.Net.WebException')) {
        $errorObj = Resolve-OfficientError -ErrorObject $ex
        Write-Verbose "Could not import Officient departments. Error at Line '$($errorObj.ScriptLineNumber)': $($errorObj.Line). Error: $($errorObj.ErrorDetails)"
        Throw "Could not import Officient departments. Error: $($errorObj.FriendlyMessage)"
    } else {
        Write-Verbose "Could not import Officient departments. Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"
        Throw "Could not import Officient departments. Error: $($ex.Exception.Message)"
    }
}
