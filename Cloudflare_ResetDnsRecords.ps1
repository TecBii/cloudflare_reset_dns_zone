<#
.SYNOPSIS
Resets the DNS in Cloudflare.
.DESCRIPTION
This script can be used to purge the dns records of a cloudflare domain.
.PARAMETER ZoneId
The Zone ID that are provided to the right of overview, in the cloudflare portal.
.PARAMETER ApiToken
Token which needs to be generated with edit Zone DNS permission.
#>
Param(
    [Parameter(Mandatory)]
    [string] $ZoneId,
    [Parameter(Mandatory)]
    [string] $ApiToken
)

# Get all records from Cloudflare.
try {
    $response = Invoke-RestMethod -ContentType "application/json" -Uri "https://api.cloudflare.com/client/v4/zones/$($ZoneId)/dns_records?order=type&direction=desc&match=all" -Method "GET" -Headers @{Authorization = "Bearer $ApiToken" } -UseBasicParsing
}
catch {
    Write-Output "Couldn't finish the script succesfully. StatusCode($($_.Exception.Response.StatusCode.value__ )) StatusDescription($($_.Exception.Response.StatusDescription))"
    Exit
}

# Objects found in the http request.
$countOfRecords = $response.result.Count

# Message to make the user understand the consequences.
Write-Output "$($countOfRecords) records found, are you sure you want to purge the dns? (all records will be removed)"
$answer = Read-Host -Prompt "Do you still want to continue? [Y/N]"

if ($answer.ToUpper() -eq "Y") {
    # Loop through everything and delete!
    foreach ($record in $response.result) {
        try {
        $response = Invoke-RestMethod -ContentType "application/json" -Uri "https://api.cloudflare.com/client/v4/zones/$($zoneId)/dns_records/$($record.id)" -Method "DELETE" -Headers $headers -UseBasicParsing
        }
        catch {
            Write-Output "Couldn't finish the script succesfully. StatusCode($($_.Exception.Response.StatusCode.value__ )) StatusDescription($($_.Exception.Response.StatusDescription))"
            Exit
        }
        Write-Output "Record of zone_type '$($record.type)' and zone_name '($($record.name))' has been deleted."
    }

    Write-Output "$($countOfRecords) records has been deleted."
    Exit
}

Write-Output "Okay - nothing has changed, have a great day. :)"
