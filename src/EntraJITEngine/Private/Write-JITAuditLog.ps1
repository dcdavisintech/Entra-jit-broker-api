function Write-JITAuditLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$UserPrincipalName,

        [Parameter(Mandatory = $true)]
        [string]$RoleName,

        [Parameter(Mandatory = $false)]
        [string]$RoleId,

        [Parameter(Mandatory = $false)]
        [string]$Justification,

        [Parameter(Mandatory = $false)]
        [string]$TicketNumber,

        [Parameter(Mandatory = $false)]
        [int]$DurationHours = 2,

        [Parameter(Mandatory = $false)]
        [string]$Status = "Approved",

        [Parameter(Mandatory = $false)]
        [string]$CorrelationId
    )

    $logDir = Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\logs"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    $logFile = Join-Path -Path $logDir -ChildPath "JIT_Audit_Events.json"

    $logEntry = [PSCustomObject]@{
        Timestamp         = (Get-Date).ToUniversalTime().ToString("o")
        CorrelationId     = $CorrelationId
        UserPrincipalName = $UserPrincipalName
        RoleName          = $RoleName
        RoleId            = $RoleId
        TicketNumber      = $TicketNumber
        Justification     = $Justification
        DurationHours     = $DurationHours
        Status            = $Status
    }

    $existingLogs = @()
    if (Test-Path $logFile) {
        $content = Get-Content $logFile -Raw
        if (-not [string]::IsNullOrWhiteSpace($content)) {
            $existingLogs = @($content | ConvertFrom-Json)
        }
    }

    $existingLogs += $logEntry
    $existingLogs | ConvertTo-Json -Depth 5 | Set-Content -Path $logFile -Encoding utf8
}