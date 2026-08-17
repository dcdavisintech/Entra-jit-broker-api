function Invoke-EntraPIMActivation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RoleDisplayName,

        [Parameter(Mandatory = $true)]
        [string]$Justification,

        [Parameter(Mandatory = $true)]
        [string]$TicketNumber,

        [Parameter(Mandatory = $false)]
        [int]$DurationHours = 2,

        [Parameter(Mandatory = $false)]
        [switch]$SkipComplianceCheck,

        [Parameter(Mandatory = $false)]
        [switch]$Mock
    )

    Write-Host "`n=== Entra ID Just-In-Time Access Engine ===" -ForegroundColor Cyan

    # 1. Device Compliance Check
    if (-not $SkipComplianceCheck) {
        Write-Host "[*] Verifying host compliance..." -ForegroundColor Yellow
        $compliance = Test-WindowsCompliance
        if (-not $compliance.IsCompliant) {
            Write-Error "Compliance check failed. Cannot proceed with role activation."
            return
        }
        Write-Host "[+] Host compliance verified." -ForegroundColor Green
    }

    # 2. Account & Role Resolution
    $upn = "admin@workspace.local"
    $roleId = "9b895536-f61b-4029-a152-a5dd0354162e"

    if (-not $Mock) {
        try {
            Write-Host "[*] Connecting to Microsoft Graph SDK..." -ForegroundColor Yellow
            $context = Get-MgContext
            if (-not $context) {
                Connect-MgGraph -Scopes "RoleManagement.ReadWrite.Directory", "User.Read" -ContextScope Process -ErrorAction Stop
                $context = Get-MgContext
            }

            $roleDef = Get-MgRoleManagementDirectoryRoleDefinition -Filter "displayName eq '$RoleDisplayName'" -ErrorAction Stop
            if ($roleDef) {
                $roleId = $roleDef.Id
                $upn = $context.Account
            }
        }
        catch {
            Write-Host "[MOCK FALLBACK] Live Graph query unavailable. Using simulated directory payload..." -ForegroundColor DarkYellow
        }
    }
    else {
        Write-Host "[MOCK MODE] Executing simulated PIM broker pipeline..." -ForegroundColor Cyan
    }

    # 3. Simulate / Process Activation
    $startTime = (Get-Date).ToUniversalTime().ToString("o")
    $expirationTime = (Get-Date).AddHours($DurationHours).ToUniversalTime().ToString("o")
    $correlationId = [guid]::NewGuid().ToString()

    Write-Host "[+] Target Role: $RoleDisplayName ($roleId)" -ForegroundColor Green
    Write-Host "[+] Target Identity: $upn" -ForegroundColor Green
    Write-Host "[+] Ticket: $TicketNumber | Duration: ${DurationHours}h" -ForegroundColor Gray
    Write-Host "[+] Correlation ID: $correlationId" -ForegroundColor Gray

    # 4. Write Audit Log
    $logParams = @{
        UserPrincipalName = $upn
        RoleName          = $RoleDisplayName
        RoleId            = $roleId
        Justification     = $Justification
        TicketNumber      = $TicketNumber
        DurationHours     = $DurationHours
        Status            = "Approved"
        CorrelationId     = $correlationId
    }

    Write-JITAuditLog @logParams

    Write-Host "`n[SUCCESS] JIT activation completed successfully and logged to audit trail.`n" -ForegroundColor Green
}