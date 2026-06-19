Describe 'Get-TemplateHealth' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..\..')).Path
        $script:ScriptPath = Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Get-TemplateHealth.ps1'
    }

    BeforeEach {
        $script:TempRepo = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([System.Guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $script:TempRepo -Force | Out-Null
    }

    AfterEach {
        if ($script:TempRepo -and (Test-Path -LiteralPath $script:TempRepo)) {
            Remove-Item -LiteralPath $script:TempRepo -Recurse -Force
        }
    }

    It 'reports the expected health areas' {
        $output = & $script:ScriptPath | Out-String

        $output | Should -Match 'Generated Markdown'
        $output | Should -Match 'Runtime Policy'
        $output | Should -Match 'Template Version'
        $output | Should -Match 'Agent Workflows'
        $output | Should -Match 'Git Release Posture'
    }

    It 'returns parseable JSON output' {
        $json = & $script:ScriptPath -AsJson | Out-String
        $report = $json | ConvertFrom-Json

        $report.Summary.Total | Should -BeGreaterThan 0
        $report.Items.Area | Should -Contain 'Agent Workflows'
        $report.Items.Area | Should -Contain 'Git Release Posture'
    }

    It 'reports missing workflow documentation as an issue' {
        Set-Content -LiteralPath (Join-Path -Path $script:TempRepo -ChildPath 'VERSION') -Value '1.2.3' -NoNewline
        Set-Content -LiteralPath (Join-Path -Path $script:TempRepo -ChildPath 'README.md') -Value '![Template Version](https://img.shields.io/badge/template-1.2.3-blue)'

        $json = & $script:ScriptPath -RepoRoot $script:TempRepo -AsJson | Out-String
        $report = $json | ConvertFrom-Json
        $workflowItem = $report.Items | Where-Object { $_.Name -eq 'Agent workflow documentation' }

        $workflowItem.Status | Should -Be 'Issue'
        $workflowItem.Message | Should -Match 'docs/agent-workflows.md'
    }

    It 'reports release tag posture without failing by default' {
        Set-Content -LiteralPath (Join-Path -Path $script:TempRepo -ChildPath 'VERSION') -Value '1.2.3' -NoNewline

        { & $script:ScriptPath -RepoRoot $script:TempRepo } | Should -Not -Throw
        $json = & $script:ScriptPath -RepoRoot $script:TempRepo -AsJson | Out-String
        $report = $json | ConvertFrom-Json

        $report.Items.Area | Should -Contain 'Git Release Posture'
    }

    It 'fails with FailOnIssue when issues are present' {
        Set-Content -LiteralPath (Join-Path -Path $script:TempRepo -ChildPath 'VERSION') -Value '1.2.3' -NoNewline

        { & $script:ScriptPath -RepoRoot $script:TempRepo -FailOnIssue } | Should -Throw -ExpectedMessage '*Template health found*'
    }
}