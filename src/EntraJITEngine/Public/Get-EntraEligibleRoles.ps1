function Get-EntraEligibleRoles {
    [CmdletBinding()]
    param()

    process {
        $context = Get-MgContext
        if (-not $context) {
            Throw "Not connected to Microsoft Graph. Run 'Connect-MgGraph' first."
        }

        $userId = $context.AccountId
        Write-Verbose "Fetching eligible PIM schedules for User ID: $userId"

        $filter = "principalId eq '$userId'"
        $eligibleSchedules = Get-MgRoleManagementDirectoryRoleEligibilityScheduleInstance -Filter $filter -ExpandProperty "roleDefinition"

        if (-not $eligibleSchedules) {
            Write-Host "No eligible PIM roles found for user $userId." -ForegroundColor Yellow
            return
        }

        $results = foreach ($schedule in $eligibleSchedules) {
            [PSCustomObject]@{
                RoleName         = $schedule.RoleDefinition.DisplayName
                RoleDefinitionId = $schedule.RoleDefinitionId
                PrincipalId      = $schedule.PrincipalId
                MemberType       = $schedule.MemberType
                Status           = $schedule.Status
            }
        }

        return $results
    }
}