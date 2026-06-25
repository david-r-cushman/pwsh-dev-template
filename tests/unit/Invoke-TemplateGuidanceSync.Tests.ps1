Describe 'Invoke-TemplateGuidanceSync' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..\..')).Path
        $script:SyncScript = Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Invoke-TemplateGuidanceSync.ps1'
        $script:GuidanceFiles = @(
            'AGENTS.md'
            '.github/copilot-instructions.md'
            '.codex/skills/downstream-repo-cleanup/SKILL.md'
            '.codex/skills/downstream-repo-cleanup/agents/openai.yaml'
            'docs/agent-workflows.md'
            'docs/ai-behavioral-contract.md'
            'docs/ai-interaction-loop.md'
            'docs/copilot-instructions-reference.md'
            'docs/powershell-ai-operating-model.md'
            'docs/decisions/README.md'
            'scripts/Initialize-DownstreamRepo.ps1'
        )

        $script:InvokeSyncScript = {
            param(
                [Parameter()]
                [string[]]$ExtraArguments = @()
            )

            $arguments = @(
                '-NoProfile'
                '-File'
                $script:SyncScript
                '-TemplatePath'
                $script:TemplateRepo
                '-Path'
                $script:TargetRepo
            ) + $ExtraArguments

            $output = & pwsh @arguments 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw ($output -join [Environment]::NewLine)
            }

            return $output
        }
    }

    BeforeEach {
        $script:TestRoot = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ('pwsh-template-sync-{0}' -f [guid]::NewGuid())
        New-Item -ItemType Directory -Path $script:TestRoot | Out-Null
        $script:TemplateRepo = Join-Path -Path $script:TestRoot -ChildPath 'pwsh-dev-template'
        $script:TargetRepo = Join-Path -Path $script:TestRoot -ChildPath 'downstream-repo'
        New-Item -ItemType Directory -Path $script:TemplateRepo, $script:TargetRepo | Out-Null

        Set-Content -LiteralPath (Join-Path -Path $script:TemplateRepo -ChildPath 'VERSION') -Value '0.6.2' -Encoding utf8

        foreach ($relativePath in $script:GuidanceFiles) {
            $templatePath = Join-Path -Path $script:TemplateRepo -ChildPath $relativePath
            $templateDirectory = Split-Path -Path $templatePath -Parent
            New-Item -ItemType Directory -Path $templateDirectory -Force | Out-Null
            Set-Content -LiteralPath $templatePath -Value ('template content for {0}' -f $relativePath) -Encoding utf8
        }

        Set-Content -LiteralPath (Join-Path -Path $script:TargetRepo -ChildPath 'README.md') -Value @(
            '# Downstream Repo'
            ''
            'Project-owned README content.'
        ) -Encoding utf8

        & git -C $script:TargetRepo init -q -b work/sync | Out-Null
        & git -C $script:TargetRepo config user.email 'test@example.invalid' | Out-Null
        & git -C $script:TargetRepo config user.name 'Test User' | Out-Null
        & git -C $script:TargetRepo add . | Out-Null
        & git -C $script:TargetRepo commit -m 'initial target' | Out-Null
    }

    AfterEach {
        if (Test-Path -LiteralPath $script:TestRoot) {
            Remove-Item -LiteralPath $script:TestRoot -Recurse -Force
        }
    }

    It 'detects missing sync files, cleanup assets, and a missing README badge' {
        $output = & $script:InvokeSyncScript

        $output | Should -Contain 'Drift: True'
        $output | Should -Contain 'README badge:'
        $output -join "`n" | Should -Match 'AGENTS\.md\s+Missing'
        $output -join "`n" | Should -Match 'README\.md\s+Missing'
    }

    It 'applies approved sync files, cleanup assets, and the README badge' {
        Set-Content -LiteralPath (Join-Path -Path $script:TargetRepo -ChildPath 'local-only.txt') -Value 'keep me' -Encoding utf8
        & git -C $script:TargetRepo add local-only.txt | Out-Null
        & git -C $script:TargetRepo commit -m 'add local file' | Out-Null

        & $script:InvokeSyncScript -ExtraArguments @('-Apply') | Out-Null

        foreach ($relativePath in $script:GuidanceFiles) {
            $templateContent = Get-Content -Raw -LiteralPath (Join-Path -Path $script:TemplateRepo -ChildPath $relativePath)
            $targetContent = Get-Content -Raw -LiteralPath (Join-Path -Path $script:TargetRepo -ChildPath $relativePath)
            $targetContent | Should -Be $templateContent
        }

        Get-Content -Raw -LiteralPath (Join-Path -Path $script:TargetRepo -ChildPath 'local-only.txt') | Should -Match 'keep me'
        Get-Content -Raw -LiteralPath (Join-Path -Path $script:TargetRepo -ChildPath 'README.md') |
            Should -Match '!\[Template Version\]\(https://img\.shields\.io/badge/template-0\.6\.2-blue\)'
    }

    It 'syncs cleanup workflow assets into downstream repos that predate cleanup support' {
        & $script:InvokeSyncScript -ExtraArguments @('-Apply') | Out-Null

        Test-Path -LiteralPath (Join-Path -Path $script:TargetRepo -ChildPath 'scripts/Initialize-DownstreamRepo.ps1') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path -Path $script:TargetRepo -ChildPath '.codex/skills/downstream-repo-cleanup/SKILL.md') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path -Path $script:TargetRepo -ChildPath '.codex/skills/downstream-repo-cleanup/agents/openai.yaml') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path -Path $script:TargetRepo -ChildPath 'docs/agent-workflows.md') | Should -BeTrue
    }
    It 'does not sync numbered ADR files' {
        $templateDecisionPath = Join-Path -Path $script:TemplateRepo -ChildPath 'docs/decisions/0001-template-decision.md'
        $targetDecisionPath = Join-Path -Path $script:TargetRepo -ChildPath 'docs/decisions/0001-downstream-decision.md'
        New-Item -ItemType Directory -Path (Split-Path -Path $templateDecisionPath -Parent), (Split-Path -Path $targetDecisionPath -Parent) -Force | Out-Null
        Set-Content -LiteralPath $templateDecisionPath -Value 'template-owned decision' -Encoding utf8
        Set-Content -LiteralPath $targetDecisionPath -Value 'downstream-owned decision' -Encoding utf8
        & git -C $script:TargetRepo add docs/decisions/0001-downstream-decision.md | Out-Null
        & git -C $script:TargetRepo commit -m 'add downstream decision' | Out-Null

        & $script:InvokeSyncScript -ExtraArguments @('-Apply') | Out-Null

        Test-Path -LiteralPath (Join-Path -Path $script:TargetRepo -ChildPath 'docs/decisions/README.md') | Should -BeTrue
        Get-Content -Raw -LiteralPath $targetDecisionPath | Should -Match 'downstream-owned decision'
        Test-Path -LiteralPath (Join-Path -Path $script:TargetRepo -ChildPath 'docs/decisions/0001-template-decision.md') | Should -BeFalse
    }

    It 'updates an existing README template badge without changing unrelated content' {
        Set-Content -LiteralPath (Join-Path -Path $script:TargetRepo -ChildPath 'README.md') -Value @(
            '# Downstream Repo'
            ''
            '![Template Version](https://img.shields.io/badge/template-0.6.1-blue)'
            ''
            'Project-owned README content.'
        ) -Encoding utf8
        & git -C $script:TargetRepo add README.md | Out-Null
        & git -C $script:TargetRepo commit -m 'add old badge' | Out-Null

        & $script:InvokeSyncScript -ExtraArguments @('-Apply') | Out-Null

        $readme = Get-Content -Raw -LiteralPath (Join-Path -Path $script:TargetRepo -ChildPath 'README.md')
        $readme | Should -Match 'template-0\.6\.2-blue'
        $readme | Should -Match 'Project-owned README content\.'
        $readme | Should -Not -Match 'template-0\.6\.1-blue'
    }

    It 'inserts a missing README badge after existing badge lines' {
        Set-Content -LiteralPath (Join-Path -Path $script:TargetRepo -ChildPath 'README.md') -Value @(
            '# Downstream Repo'
            ''
            '[![CI](https://example.invalid/ci.svg)](https://example.invalid/ci)'
            '![PowerShell 7.4](https://img.shields.io/badge/PowerShell-7.4-blue)'
            ''
            'Project-owned README content.'
        ) -Encoding utf8
        & git -C $script:TargetRepo add README.md | Out-Null
        & git -C $script:TargetRepo commit -m 'add badges' | Out-Null

        & $script:InvokeSyncScript -ExtraArguments @('-Apply') | Out-Null

        $readmeLines = Get-Content -LiteralPath (Join-Path -Path $script:TargetRepo -ChildPath 'README.md')
        $readmeLines[4] | Should -Be '![Template Version](https://img.shields.io/badge/template-0.6.2-blue)'
        $readmeLines[5] | Should -Be ''
        $readmeLines[6] | Should -Be 'Project-owned README content.'
    }

    It 'refuses to apply on main' {
        & git -C $script:TargetRepo switch -q -c main | Out-Null

        { & $script:InvokeSyncScript -ExtraArguments @('-Apply') } | Should -Throw -ExpectedMessage '*protected branch "main"*'
    }

    It 'refuses to apply with a dirty working tree' {
        Set-Content -LiteralPath (Join-Path -Path $script:TargetRepo -ChildPath 'dirty.txt') -Value 'dirty' -Encoding utf8

        { & $script:InvokeSyncScript -ExtraArguments @('-Apply') } | Should -Throw -ExpectedMessage '*uncommitted*changes*'
    }

    It 'supports WhatIf without changing files' {
        & $script:InvokeSyncScript -ExtraArguments @('-Apply', '-WhatIf') | Out-Null

        foreach ($relativePath in $script:GuidanceFiles) {
            Test-Path -LiteralPath (Join-Path -Path $script:TargetRepo -ChildPath $relativePath) | Should -BeFalse
        }
    }

    It 'returns JSON output for automation' {
        $json = & $script:InvokeSyncScript -ExtraArguments @('-OutputFormat', 'Json') | ConvertFrom-Json

        $json.TemplateVersion | Should -Be '0.6.2'
        $json.TargetPath | Should -Be (Resolve-Path -LiteralPath $script:TargetRepo).Path
        $json.HasDrift | Should -BeTrue
        $json.Files.Count | Should -Be $script:GuidanceFiles.Count
    }

    It 'supports FailOnDrift' {
        { & $script:InvokeSyncScript -ExtraArguments @('-FailOnDrift') } | Should -Throw -ExpectedMessage '*drift detected*'
    }

    It 'reports current state after applying guidance and cleanup assets' {
        & $script:InvokeSyncScript -ExtraArguments @('-Apply') | Out-Null
        & git -C $script:TargetRepo add . | Out-Null
        & git -C $script:TargetRepo commit -m 'sync guidance' | Out-Null

        $output = & $script:InvokeSyncScript

        $output | Should -Contain 'Drift: False'
        $output -join "`n" | Should -Match 'AGENTS\.md\s+Current'
        $output -join "`n" | Should -Match 'Initialize-DownstreamRepo\.ps1\s+Current'
        $output -join "`n" | Should -Match 'README\.md\s+Current'
    }

    It 'fails clearly for non-Git targets' {
        $nonGitTarget = Join-Path -Path $script:TestRoot -ChildPath 'not-git'
        New-Item -ItemType Directory -Path $nonGitTarget | Out-Null

        {
            $output = & pwsh -NoProfile -File $script:SyncScript -TemplatePath $script:TemplateRepo -Path $nonGitTarget 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw ($output -join [Environment]::NewLine)
            }
        } | Should -Throw -ExpectedMessage '*not a Git repository*'
    }
}
