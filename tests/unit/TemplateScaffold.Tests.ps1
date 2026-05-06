Describe 'Template scaffold' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..\..')).Path
    }

    It 'has PowerShell script templates that parse without syntax errors' {
        $scriptFiles = Get-ChildItem -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'templates') -Filter '*.ps1' -Recurse -File
        $scriptFiles | Should -Not -BeNullOrEmpty

        foreach ($scriptFile in $scriptFiles) {
            $tokens = $null
            $parseErrors = $null
            [System.Management.Automation.Language.Parser]::ParseFile($scriptFile.FullName, [ref]$tokens, [ref]$parseErrors) | Out-Null

            $parseErrors | Should -BeNullOrEmpty -Because ('{0} should parse successfully' -f $scriptFile.FullName)
        }
    }

    It 'has PowerShell data files that import without parse errors' {
        $dataFiles = Get-ChildItem -LiteralPath $script:RepoRoot -Filter '*.psd1' -Recurse -File
        $dataFiles | Should -Not -BeNullOrEmpty

        foreach ($dataFile in $dataFiles) {
            { Import-PowerShellDataFile -LiteralPath $dataFile.FullName } |
                Should -Not -Throw -Because ('{0} should import successfully' -f $dataFile.FullName)
        }
    }
}
