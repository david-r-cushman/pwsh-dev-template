Describe 'Invoke-MarkdownValidation' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..\..')).Path
        $script:ScriptPath = Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Invoke-MarkdownValidation.ps1'
        $script:ConfigContent = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath '.markdownlint.json')

        function New-MarkdownValidationRepo {
            [CmdletBinding(SupportsShouldProcess)]
            param(
                [Parameter(Mandatory)]
                [string]$Path,

                [Parameter(Mandatory)]
                [string]$ReadmeContent,

                [Parameter()]
                [string]$ConfigContent = $script:ConfigContent
            )

            New-Item -ItemType Directory -Path $Path -Force | Out-Null
            [System.IO.File]::WriteAllText((Join-Path -Path $Path -ChildPath '.markdownlint.json'), $ConfigContent, [System.Text.UTF8Encoding]::new($false))
            [System.IO.File]::WriteAllText((Join-Path -Path $Path -ChildPath 'README.md'), $ReadmeContent, [System.Text.UTF8Encoding]::new($false))
        }

        function Invoke-MarkdownValidationScript {
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
        $script:TempRoot = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ('markdown-validation-{0}' -f [guid]::NewGuid())
        $script:RepoPath = Join-Path -Path $script:TempRoot -ChildPath 'repo'
        New-Item -ItemType Directory -Path $script:TempRoot -Force | Out-Null
    }

    AfterEach {
        if (Test-Path -LiteralPath $script:TempRoot) {
            Remove-Item -LiteralPath $script:TempRoot -Recurse -Force
        }
    }

    It 'fails when headings and lists are not surrounded by blank lines' {
        New-MarkdownValidationRepo -Path $script:RepoPath -ReadmeContent @'
# Repo Title
Intro text.
## Missing Space
- item one
## Another Heading
'@

        {
            Invoke-MarkdownValidationScript -RepoPath $script:RepoPath
        } | Should -Throw -ExpectedMessage '*MD022*MD032*'
    }

    It 'passes when headings and lists have the expected blank lines' {
        New-MarkdownValidationRepo -Path $script:RepoPath -ReadmeContent @'
# Repo Title

Intro text.

## Heading

- item one
- item two

## Another Heading

More text.
'@

        { Invoke-MarkdownValidationScript -RepoPath $script:RepoPath } | Should -Not -Throw
    }

    It 'ignores heading and list markers inside fenced code blocks' {
        New-MarkdownValidationRepo -Path $script:RepoPath -ReadmeContent @'
# Repo Title

```powershell
## Not A Real Heading
- not a real list item
```

## Real Heading

Paragraph.
'@

        { Invoke-MarkdownValidationScript -RepoPath $script:RepoPath } | Should -Not -Throw
    }
}