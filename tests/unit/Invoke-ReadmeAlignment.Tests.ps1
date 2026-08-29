Describe 'Invoke-ReadmeAlignment' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..\..')).Path
        $script:ScriptPath = Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Invoke-ReadmeAlignment.ps1'
        $script:SkeletonPath = Join-Path -Path $script:RepoRoot -ChildPath 'templates/downstream/README.md'

        function New-ReadmeAlignmentRepo {
            [CmdletBinding(SupportsShouldProcess)]
            param(
                [Parameter(Mandatory)]
                [string]$Path,

                [Parameter()]
                [string]$ReadmeContent = @'
# winget-pwsh-automation

![Template Version](https://img.shields.io/badge/template-0.15.0-blue)

Custom summary for this repository.

## Engineering Principles in Practice

Repository-owned engineering guidance.

## Portfolio Context

Repository-owned portfolio context.

## Extra Context

Repository-specific extra section.
'@
            )

            New-Item -ItemType Directory -Path $Path -Force | Out-Null

            $files = @{
                'README.md' = $ReadmeContent
                'AGENTS.md' = 'derived from pwsh-dev-template'
                '.github/copilot-instructions.md' = 'derived from pwsh-dev-template'
                '.codex/skills/downstream-guidance-sync/SKILL.md' = 'sync skill'
                'eng/runtime-policy.json' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'eng/runtime-policy.json')
                'scripts/Update-GeneratedMarkdown.ps1' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Update-GeneratedMarkdown.ps1')
                'scripts/Invoke-RepoChecks.ps1' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Invoke-RepoChecks.ps1')
                'scripts/Invoke-TemplateGuidanceSync.ps1' = 'sync script'
                'templates/downstream/README.md' = Get-Content -Raw -LiteralPath $script:SkeletonPath
            }

            foreach ($relativePath in $files.Keys) {
                $fullPath = Join-Path -Path $Path -ChildPath $relativePath
                $parent = Split-Path -Path $fullPath -Parent
                if ($parent -and (-not (Test-Path -LiteralPath $parent))) {
                    New-Item -ItemType Directory -Path $parent -Force | Out-Null
                }

                [System.IO.File]::WriteAllText($fullPath, $files[$relativePath], [System.Text.UTF8Encoding]::new($false))
            }

            & git -C $Path init -q -b work/readme | Out-Null
            & git -C $Path config user.email 'test@example.invalid' | Out-Null
            & git -C $Path config user.name 'Test User' | Out-Null
            & git -C $Path add . | Out-Null
            & git -C $Path commit -m 'initial repo' | Out-Null
            & git -C $Path branch main | Out-Null
            & git -C $Path remote add origin $Path | Out-Null
            & git -C $Path fetch origin | Out-Null
            & git -C $Path branch --set-upstream-to=origin/work/readme work/readme | Out-Null
        }

        function Invoke-AlignmentScript {
            param(
                [Parameter(Mandatory)]
                [string]$RepoPath,

                [Parameter()]
                [string[]]$ExtraArguments = @()
            )

            $arguments = @(
                '-NoProfile'
                '-File'
                $script:ScriptPath
                '-RepoRoot'
                $RepoPath
            ) + $ExtraArguments

            $output = & pwsh @arguments 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw ($output -join [Environment]::NewLine)
            }

            return $output
        }
    }

    BeforeEach {
        $script:TempRoot = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ('readme-alignment-{0}' -f [guid]::NewGuid())
        $script:RepoPath = Join-Path -Path $script:TempRoot -ChildPath 'winget-pwsh-automation'
        New-ReadmeAlignmentRepo -Path $script:RepoPath
    }

    AfterEach {
        if (Test-Path -LiteralPath $script:TempRoot) {
            Remove-Item -LiteralPath $script:TempRoot -Recurse -Force
        }
    }

    It 'reports missing and realigned shared sections in audit mode' {
        $output = Invoke-AlignmentScript -RepoPath $script:RepoPath
        $text = $output -join "`n"

        $text | Should -Match 'Portfolio Context'
        $text | Should -Match 'Engineering Principles in Practice'
        $text | Should -Match 'Missing'
        $text | Should -Match 'Extra sections:'
        $text | Should -Match 'Extra Context'
    }

    It 'defines the required remote-freshness stop conditions before alignment can apply changes' {
        $content = Get-Content -Raw -LiteralPath $script:ScriptPath

        $content | Should -Match 'function Assert-RemoteFreshness'
        $content | Should -Match 'origin is not configured'
        $content | Should -Match 'no upstream'
        $content | Should -Match 'behind its upstream'
        $content | Should -Match 'has diverged from its upstream'
        $content | Should -Match 'latest origin/main'
        $content | Should -Match 'if \(\$Apply -and \$hasChanges\) \{\s*Assert-RemoteFreshness'
    }

    It 'realigns the README while preserving portfolio and extra sections' {
        Invoke-AlignmentScript -RepoPath $script:RepoPath -ExtraArguments @('-Apply') | Out-Null

        $readme = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoPath -ChildPath 'README.md')
        $readme | Should -Match 'Quick navigation:'
        $readme | Should -Match '## Portfolio Context'
        $readme | Should -Match 'Repository-owned portfolio context\.'
        $readme | Should -Match '## Engineering Principles in Practice'
        $readme | Should -Match '## Validation And Maintenance'
        $readme | Should -Match '## Template Versioning'
        $readme | Should -Match '## Extra Context'
    }

    It 'returns parseable JSON output' {
        $json = Invoke-AlignmentScript -RepoPath $script:RepoPath -ExtraArguments @('-OutputFormat', 'Json')
        $report = $json | ConvertFrom-Json

        $report.RepositoryName | Should -Be 'winget-pwsh-automation'
        $report.HasChanges | Should -BeTrue
        $report.StandardSections.Heading | Should -Contain 'Portfolio Context'
    }

    It 'stops when required template-derived assets are missing' {
        Remove-Item -LiteralPath (Join-Path -Path $script:RepoPath -ChildPath 'eng/runtime-policy.json') -Force

        {
            Invoke-AlignmentScript -RepoPath $script:RepoPath
        } | Should -Throw -ExpectedMessage '*Missing: eng/runtime-policy.json*'
    }
}
