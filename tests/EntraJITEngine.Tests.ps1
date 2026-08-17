BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '..\src\EntraJITEngine\EntraJITEngine.psd1'
    Import-Module (Resolve-Path $modulePath) -Force

    $logDir = Join-Path $PSScriptRoot '..\logs'
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }
}

Describe 'EntraJITEngine Module Architecture' {
    It 'Exports core public cmdlets' {
        $exportedCommands = (Get-Command -Module EntraJITEngine).Name
        $exportedCommands | Should -Contain 'Get-EntraEligibleRoles'
        $exportedCommands | Should -Contain 'Invoke-EntraPIMActivation'
    }

    It 'Evaluates host compliance correctly' {
        InModuleScope 'EntraJITEngine' {
            $compliance = Test-WindowsCompliance -Mock
            $compliance | Should -Not -BeNullOrEmpty
            $compliance.IsCompliant | Should -Be $true
        }
    }

    It 'Generates SIEM-ready structured JSON audit records on activation' {
        $result = Invoke-EntraPIMActivation `
            -RoleDisplayName 'Security Reader' `
            -Justification 'Automated CI test execution' `
            -TicketNumber 'INC-AUTO-TEST' `
            -DurationHours 1 `
            -Mock

        $result | Should -Not -BeNullOrEmpty

        $logPath = Join-Path $PSScriptRoot '..\logs\JIT_Audit_Events.json'
        Test-Path $logPath | Should -Be $true

        $logContent = Get-Content -Path $logPath -Raw | ConvertFrom-Json
        $logContent | Should -Not -BeNullOrEmpty
    }
}