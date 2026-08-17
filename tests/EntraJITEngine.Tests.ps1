BeforeAll {
    $modulePath = Resolve-Path "$PSScriptRoot/../src/EntraJITEngine/EntraJITEngine.psd1"
    Import-Module $modulePath -Force
}

Describe 'EntraJITEngine Module Architecture' {
    It 'Exports core public cmdlets' {
        $exportedCommands = (Get-Command -Module EntraJITEngine).Name
        $exportedCommands | Should -Contain 'Get-EntraEligibleRoles'
        $exportedCommands | Should -Contain 'Invoke-EntraPIMActivation'
    }

    It 'Discovers eligible roles in mock simulation mode' {
        $roles = Get-EntraEligibleRoles -Mock
        $roles | Should -Not -BeNullOrEmpty
        $roles.Count | Should -BeGreaterThan 0
    }

    It 'Executes JIT role activation in mock simulation mode' {
        $activation = Invoke-EntraPIMActivation `
            -RoleDisplayName 'Security Reader' `
            -Justification 'Automated CI test execution' `
            -TicketNumber 'INC-AUTO-TEST' `
            -DurationHours 1 `
            -Mock

        $activation | Should -Not -BeNullOrEmpty
        $activation.Status | Should -Be 'Success'
    }
}