Describe 'EntraJITEngine Module Architecture' {
    BeforeAll {
        $modulePath = Resolve-Path "$PSScriptRoot/../src/EntraJITEngine/EntraJITEngine.psd1"
        Import-Module $modulePath -Force
    }

    It 'Exports core public cmdlets' {
        $commands = (Get-Command -Module EntraJITEngine).Name
        ($commands -contains 'Get-EntraEligibleRoles') | Should Be $true
        ($commands -contains 'Invoke-EntraPIMActivation') | Should Be $true
    }

    It 'Executes role discovery in mock mode without errors' {
        { Get-EntraEligibleRoles -Mock } | Should Not Throw
    }

    It 'Executes JIT role activation in mock mode without errors' {
        {
            Invoke-EntraPIMActivation `
                -RoleDisplayName 'Security Reader' `
                -Justification 'Automated CI test execution' `
                -TicketNumber 'INC-AUTO-TEST' `
                -DurationHours 1 `
                -Mock
        } | Should Not Throw
    }
}