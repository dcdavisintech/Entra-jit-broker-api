function Get-EntraEligibleRoles {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$Mock
    )

    if ($Mock) {
        Write-Verbose "Running in Mock mode. Generating simulated eligible Entra ID roles."
        return @(
            [PSCustomObject]@{
                RoleDefinitionId = "62e90394-69f5-4237-9190-012177145e10"
                RoleDisplayName  = "Global Reader"
                PrincipalId      = "88d3885c-6b3a-4a25-8f64-d32e92c23bc9"
                PrincipalName    = "Demo Admin"
                Status           = "Eligible"
                MaxDurationHours = 8
            },
            [PSCustomObject]@{
                RoleDefinitionId = "b79fbf4d-3ef9-4689-8143-76b194e85509"
                RoleDisplayName  = "Security Administrator"
                PrincipalId      = "88d3885c-6b3a-4a25-8f64-d32e92c23bc9"
                PrincipalName    = "Demo Admin"
                Status           = "Eligible"
                MaxDurationHours = 4
            }
        )
    }

    $mgContext = Get-MgContext -ErrorAction SilentlyContinue
    if (-not $mgContext) {
        throw "Not connected to Microsoft Graph. Run 'Connect-MgGraph' first or pass -Mock for simulation."
    }

    try {
        $uri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleEligibilityScheduleInstances"
        $response = Invoke-MgGraphRequest -Method GET -Uri $uri
        return $response.value
    }
    catch {
        throw "Failed to retrieve eligible roles from Microsoft Graph: $($_.Exception.Message)"
    }
}