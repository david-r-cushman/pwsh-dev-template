Describe 'Invoke-RepoChecks' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..\..')).Path
        $script:RepoChecksPath = Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Invoke-RepoChecks.ps1'
        $script:MarkdownValidationPath = Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Invoke-MarkdownValidation.ps1'
        $script:MarkdownLintConfig = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath '.markdownlint.json')

        function New-RepoChecksFixture {
            [CmdletBinding(SupportsShouldProcess)]
            param(
                [Parameter(Mandatory)]
                [string]$Path,

                [Parameter(Mandatory)]
                [string]$ReadmeContent
            )

            $scriptsPath = Join-Path -Path $Path -ChildPath 'scripts'
            New-Item -ItemType Directory -Path $scriptsPath -Force | Out-Null
            [System.IO.File]::WriteAllText((Join-Path -Path $Path -ChildPath '.markdownlint.json'), $script:MarkdownLintConfig, [System.Text.UTF8Encoding]::new($false))
            [System.IO.File]::WriteAllText((Join-Path -Path $Path -ChildPath 'README.md'), $ReadmeContent, [System.Text.UTF8Encoding]::new($false))
            [System.IO.File]::WriteAllText((Join-Path -Path $scriptsPath -ChildPath 'Invoke-RepoChecks.ps1'), (Get-Content -Raw -LiteralPath $script:RepoChecksPath), [System.Text.UTF8Encoding]::new($false))
            [System.IO.File]::WriteAllText((Join-Path -Path $scriptsPath -ChildPath 'Invoke-MarkdownValidation.ps1'), (Get-Content -Raw -LiteralPath $script:MarkdownValidationPath), [System.Text.UTF8Encoding]::new($false))
        }

        function Invoke-RepoChecksScript {
            param(
                [Parameter(Mandatory)]
                [string]$RepoPath,

                [Parameter()]
                [string[]]$ExtraArguments = @()
            )

            $scriptPath = Join-Path -Path $RepoPath -ChildPath 'scripts/Invoke-RepoChecks.ps1'
            $arguments = @(
                '-NoProfile'
                '-File'
                $scriptPath
                '-SkipAnalyzer'
                '-SkipTests'
                '-SkipGeneratedMarkdown'
                '-SkipVersionPolicy'
                '-SkipTemplateVersion'
            ) + $ExtraArguments

            $output = & pwsh @arguments 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw ($output -join [Environment]::NewLine)
            }

            return $output
        }
    }

    BeforeEach {
        $script:TempRoot = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ('repo-checks-{0}' -f [guid]::NewGuid())
        $script:FixturePath = Join-Path -Path $script:TempRoot -ChildPath 'repo'
        New-Item -ItemType Directory -Path $script:TempRoot -Force | Out-Null
    }

    AfterEach {
        if (Test-Path -LiteralPath $script:TempRoot) {
            Remove-Item -LiteralPath $script:TempRoot -Recurse -Force
        }
    }

    It 'runs Markdown validation by default and fails on invalid README spacing' {
        New-RepoChecksFixture -Path $script:FixturePath -ReadmeContent @"
# Repo Title
Intro text.
## Missing Space
- item one
## Another Heading
"@

        {
            Invoke-RepoChecksScript -RepoPath $script:FixturePath
        } | Should -Throw -ExpectedMessage '*Markdown validation failed*'
    }

    It 'passes repo checks when Markdown spacing is valid' {
        New-RepoChecksFixture -Path $script:FixturePath -ReadmeContent @"
# Repo Title

Intro text.

## Heading

- item one
- item two

## Another Heading

More text.
"@

        { Invoke-RepoChecksScript -RepoPath $script:FixturePath } | Should -Not -Throw
    }

    It 'supports SkipMarkdownLint for callers that intentionally bypass Markdown validation' {
        New-RepoChecksFixture -Path $script:FixturePath -ReadmeContent @"
# Repo Title
Intro text.
## Missing Space
- item one
## Another Heading
"@

        { Invoke-RepoChecksScript -RepoPath $script:FixturePath -ExtraArguments @('-SkipMarkdownLint') } | Should -Not -Throw
    }
}