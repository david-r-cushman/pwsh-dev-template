Describe 'Test-TemplateVersion' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..\..')).Path
        $script:ScriptPath = Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Test-TemplateVersion.ps1'
        $script:NewVersionFixture = {
            param(
                [string]$Version = '1.2.3',
                [string]$BadgeVersion = $Version,
                [string]$ChangelogVersion = $Version
            )

            Set-Content -LiteralPath (Join-Path -Path $script:TempRepo -ChildPath 'VERSION') -Value $Version -NoNewline
            Set-Content -LiteralPath (Join-Path -Path $script:TempRepo -ChildPath 'README.md') -Value ('![Template Version](https://img.shields.io/badge/template-{0}-blue)' -f $BadgeVersion)
            Set-Content -LiteralPath (Join-Path -Path $script:TempRepo -ChildPath 'CHANGELOG.md') -Value ("# Changelog`n`n## {0} - 2026-06-19`n" -f $ChangelogVersion)
        }
        $script:InitializeGitRepo = {
            & git -C $script:TempRepo init -q | Out-Null
            & git -C $script:TempRepo config user.email 'test@example.invalid' | Out-Null
            & git -C $script:TempRepo config user.name 'Test User' | Out-Null
        }
        $script:CommitVersionFixture = {
            & git -C $script:TempRepo add VERSION README.md CHANGELOG.md | Out-Null
            & git -C $script:TempRepo commit -q -m 'add version fixture' | Out-Null
        }
        $script:EnableSshSigning = {
            $keyPath = Join-Path -Path $script:TempRepo -ChildPath 'id_ed25519'
            & ssh-keygen -t ed25519 -N '' -C 'test@example.invalid' -f $keyPath | Out-Null
            & git -C $script:TempRepo config gpg.format ssh | Out-Null
            & git -C $script:TempRepo config user.signingkey $keyPath | Out-Null
        }
    }

    BeforeEach {
        $script:TempRepo = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([System.Guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $script:TempRepo -Force | Out-Null
        & $script:InitializeGitRepo
    }

    AfterEach {
        if ($script:TempRepo -and (Test-Path -LiteralPath $script:TempRepo)) {
            Remove-Item -LiteralPath $script:TempRepo -Recurse -Force
        }
    }

    It 'passes when VERSION, README badge, and changelog match' {
        & $script:NewVersionFixture

        { & $script:ScriptPath -RepoRoot $script:TempRepo } | Should -Not -Throw
    }

    It 'fails when the README template badge is stale' {
        & $script:NewVersionFixture -Version '1.2.3' -BadgeVersion '1.2.2'

        { & $script:ScriptPath -RepoRoot $script:TempRepo } | Should -Throw -ExpectedMessage '*Template version validation failed*'
    }

    It 'fails when the changelog release heading is missing' {
        & $script:NewVersionFixture -Version '1.2.3' -ChangelogVersion '1.2.2'

        { & $script:ScriptPath -RepoRoot $script:TempRepo } | Should -Throw -ExpectedMessage '*Template version validation failed*'
    }

    It 'validates tag state only when CheckTag is supplied' {
        & $script:NewVersionFixture

        { & $script:ScriptPath -RepoRoot $script:TempRepo } | Should -Not -Throw
        { & $script:ScriptPath -RepoRoot $script:TempRepo -CheckTag } | Should -Throw -ExpectedMessage '*Template version validation failed*'
    }

    It 'fails when the release tag is lightweight' {
        & $script:NewVersionFixture
        & $script:CommitVersionFixture
        & git -C $script:TempRepo tag v1.2.3 | Out-Null

        { & $script:ScriptPath -RepoRoot $script:TempRepo -CheckTag } | Should -Throw -ExpectedMessage '*Template version validation failed*'
    }

    It 'fails when the release tag is unsigned annotated' {
        & $script:NewVersionFixture
        & $script:CommitVersionFixture
        & git -C $script:TempRepo tag -a v1.2.3 -m 'Release v1.2.3' | Out-Null

        { & $script:ScriptPath -RepoRoot $script:TempRepo -CheckTag } | Should -Throw -ExpectedMessage '*Template version validation failed*'
    }

    It 'passes when the release tag is signed and annotated' {
        & $script:NewVersionFixture
        & $script:CommitVersionFixture
        & $script:EnableSshSigning
        & git -C $script:TempRepo tag -s v1.2.3 -m 'Release v1.2.3' | Out-Null

        { & $script:ScriptPath -RepoRoot $script:TempRepo -CheckTag } | Should -Not -Throw
    }
}
