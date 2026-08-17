Describe "EntraJITEngine Module Architecture" {
    BeforeAll {
        $ModulePath = Join-Path $PSScriptRoot "..\src\EntraJITEngine\EntraJITEngine.psd1"
        Import-Module $ModulePath -Force
        . (Join-Path $PSScriptRoot "..\src\EntraJITEngine\Private\Test-WindowsCompliance.ps1")
    }

    It "Exports core public cmdlets" {
        $commands = @((Get-Module EntraJITEngine).ExportedCommands.Keys)
        $commands -contains "Invoke-EntraPIMActivation" | Should Be $true
        $commands -contains "Get-EntraEligibleRoles" | Should Be $true
    }

    It "Evaluates host compliance correctly" {
        $result = Test-WindowsCompliance
        $result.IsCompliant | Should Be $true
        $result.BitLockerActive | Should Be $true
        $result.DefenderActive | Should Be $true
    }

    It "Generates SIEM-ready structured JSON audit records on activation" {
        $testTicket = "INC-AUTO-TEST"
        Invoke-EntraPIMActivation `
            -RoleDisplayName "Security Reader" `
            -Justification "CI Automated Test Elevation" `
            -TicketNumber $testTicket `
            -DurationHours 1 `
            -Mock

        $logPath = Join-Path $PSScriptRoot "..\logs\JIT_Audit_Events.json"
        Test-Path $logPath | Should Be $true

        $records = Get-Content $logPath | ConvertFrom-Json
        $targetRecord = $records | Where-Object { $_.TicketNumber -eq $testTicket } | Select-Object -Last 1
        
        $targetRecord | Should Not BeNullOrEmpty
        $targetRecord.Status | Should Be "Approved"
        $targetRecord.RoleName | Should Be "Security Reader"
    }
}