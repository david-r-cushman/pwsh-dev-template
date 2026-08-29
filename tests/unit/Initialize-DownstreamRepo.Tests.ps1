Describe 'Initialize-DownstreamRepo' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..\..')).Path
        $script:ScriptPath = Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Initialize-DownstreamRepo.ps1'
        $script:TemplateVersion = '0.11.0'

        function New-TemplateLikeDownstreamRepo {
            [CmdletBinding(SupportsShouldProcess)]
            param(
                [Parameter(Mandatory)]
                [string]$Path,

                [Parameter()]
                [switch]$OmitReadmeBadge
            )

            New-Item -ItemType Directory -Path $Path -Force | Out-Null

            $files = @{
                'VERSION' = $script:TemplateVersion
                'CHANGELOG.md' = "# Changelog`n"
                'AGENTS.md' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'AGENTS.md')
                'README.md' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'README.md')
                '.github/copilot-instructions.md' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath '.github/copilot-instructions.md')
                '.github/instructions/environment-setup.md' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath '.github/instructions/environment-setup.md')
                'docs/agent-workflows.md' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'docs/agent-workflows.md')
                'docs/decisions/README.md' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'docs/decisions/README.md')
                'docs/template-evolution.md' = 'template evolution'
                'docs/decisions/0001-downstream-guidance-sync.md' = 'seed ADR'
                'docs/decisions/0002-repo-local-agent-workflows.md' = 'seed ADR'
                'docs/decisions/0003-manual-github-releases.md' = 'seed ADR'
                'docs/decisions/0004-downstream-repo-cleanup.md' = 'seed ADR'
                'docs/decisions/0005-downstream-guidance-sync-delivers-cleanup-assets.md' = 'seed ADR'
                'docs/decisions/0006-change-delivery-workflow.md' = 'seed ADR'
                'docs/decisions/0007-readme-alignment-workflow.md' = 'seed ADR'
                'scripts/Get-TemplateHealth.ps1' = 'Write-Output "health"'
                'scripts/Test-TemplateVersion.ps1' = 'Write-Output "version"'
                'scripts/Initialize-DownstreamRepo.ps1' = Get-Content -Raw -LiteralPath $script:ScriptPath
                'scripts/Invoke-RepoChecks.ps1' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Invoke-RepoChecks.ps1')
                'scripts/Invoke-MarkdownValidation.ps1' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Invoke-MarkdownValidation.ps1')
                'scripts/Test-VersionPolicy.ps1' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Test-VersionPolicy.ps1')
                'scripts/Update-GeneratedMarkdown.ps1' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Update-GeneratedMarkdown.ps1')
                'scripts/Invoke-TemplateGuidanceSync.ps1' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Invoke-TemplateGuidanceSync.ps1')
                'scripts/Invoke-ReadmeAlignment.ps1' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Invoke-ReadmeAlignment.ps1')
                '.github/workflows/ci.yml' = 'name: CI'
                '.devcontainer/devcontainer.json' = '{}'
                'eng/runtime-policy.json' = '{"runtime":{"powershellVersion":"7.4","powershellVersionLabel":"7.4.x","ubuntuVersion":"22.04","dockerImage":"mcr.microsoft.com/powershell:lts-ubuntu-22.04"},"tooling":{"pesterVersion":"6.0.0","psScriptAnalyzerVersion":"1.25.0","psReadLineVersion":"2.4.5"},"githubActions":{"runnerImage":"ubuntu-22.04"}}'
                'PesterConfiguration.psd1' = '@{}'
                'PSScriptAnalyzerSettings.psd1' = '@{}'
                'src/README.md' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'src/README.md')
                'src/TemplateModule.psd1' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'src/TemplateModule.psd1')
                'src/TemplateModule.psm1' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'src/TemplateModule.psm1')
                'src/.gitkeep' = ''
                'src/Public/.gitkeep' = ''
                'src/Private/.gitkeep' = ''
                'src/Classes/.gitkeep' = ''
                'templates/README.md' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'templates/README.md')
                'templates/downstream/README.md' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'templates/downstream/README.md')
                '.codex/skills/downstream-guidance-sync/SKILL.md' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/downstream-guidance-sync/SKILL.md')
                '.codex/skills/downstream-guidance-sync/agents/openai.yaml' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/downstream-guidance-sync/agents/openai.yaml')
                '.codex/skills/downstream-repo-cleanup/SKILL.md' = 'placeholder'
                '.codex/skills/downstream-repo-cleanup/agents/openai.yaml' = @(
                    'display_name: "Downstream Repo Cleanup"'
                    'short_description: "Normalize a new downstream repo"'
                    'default_prompt: "Use $downstream-repo-cleanup to normalize this new downstream repository."'
                ) -join "`n"
                '.codex/skills/readme-alignment/SKILL.md' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/readme-alignment/SKILL.md')
                '.codex/skills/readme-alignment/agents/openai.yaml' = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/readme-alignment/agents/openai.yaml')
                '.codex/skills/runtime-policy-update/SKILL.md' = 'runtime skill'
                '.codex/skills/runtime-policy-update/agents/openai.yaml' = 'display_name: "Runtime Policy Update"'
                '.codex/skills/template-version-release/SKILL.md' = 'release skill'
                '.codex/skills/template-version-release/agents/openai.yaml' = 'display_name: "Template Version Release"'
                'tests/unit/Invoke-TemplateGuidanceSync.Tests.ps1' = 'Describe "x" {}'
                'tests/unit/TemplateHealth.Tests.ps1' = 'Describe "x" {}'
                'tests/unit/TemplateScaffold.Tests.ps1' = 'Describe "x" {}'
                'tests/unit/TemplateVersion.Tests.ps1' = 'Describe "x" {}'
                'tests/unit/SkillScaffold.Tests.ps1' = 'Describe "x" {}'
                'tests/unit/Initialize-DownstreamRepo.Tests.ps1' = 'Describe "x" {}'
                'tests/unit/Invoke-MarkdownValidation.Tests.ps1' = 'Describe "x" {}'
                'tests/unit/Invoke-ReadmeAlignment.Tests.ps1' = 'Describe "x" {}'
                'tests/unit/Invoke-RepoChecks.Tests.ps1' = 'Describe "x" {}'
                'tests/.gitkeep' = ''
                'tests/unit/.gitkeep' = ''
                'tests/testhelpers/.gitkeep' = ''
            }

            foreach ($relativePath in $files.Keys) {
                $fullPath = Join-Path -Path $Path -ChildPath $relativePath
                $parent = Split-Path -Path $fullPath -Parent
                if ($parent -and (-not (Test-Path -LiteralPath $parent))) {
                    New-Item -ItemType Directory -Path $parent -Force | Out-Null
                }

                [System.IO.File]::WriteAllText($fullPath, $files[$relativePath], [System.Text.UTF8Encoding]::new($false))
            }

            if ($OmitReadmeBadge) {
                $readmePath = Join-Path -Path $Path -ChildPath 'README.md'
                $readmeContent = Get-Content -Raw -LiteralPath $readmePath
                $readmeContent = $readmeContent -replace '!\[Template Version\]\(https://img\.shields\.io/badge/template-[^)]+\)\r?\n', ''
                [System.IO.File]::WriteAllText($readmePath, $readmeContent, [System.Text.UTF8Encoding]::new($false))
            }

            & git -C $Path init -q -b main | Out-Null
            & git -C $Path config user.email 'test@example.invalid' | Out-Null
            & git -C $Path config user.name 'Test User' | Out-Null
            & git -C $Path add . | Out-Null
            & git -C $Path commit -m 'initial downstream template copy' | Out-Null
            & git -C $Path remote add origin $Path | Out-Null
            & git -C $Path fetch origin | Out-Null
            & git -C $Path branch --set-upstream-to=origin/main main | Out-Null
            & git -C $Path branch --set-upstream-to=origin/main main | Out-Null
        }

        function Invoke-CleanupScript {
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
        $script:TempRoot = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ('downstream-cleanup-{0}' -f [guid]::NewGuid())
        New-Item -ItemType Directory -Path $script:TempRoot -Force | Out-Null
        $script:DownstreamRepo = Join-Path -Path $script:TempRoot -ChildPath 'winget-pwsh-automation'
        New-TemplateLikeDownstreamRepo -Path $script:DownstreamRepo
    }

    AfterEach {
        if (Test-Path -LiteralPath $script:TempRoot) {
            Remove-Item -LiteralPath $script:TempRoot -Recurse -Force
        }
    }

    It 'reports expected actions in audit mode without changing files' {
        $output = & Invoke-CleanupScript -RepoPath $script:DownstreamRepo
        $text = $output -join "`n"

        $text | Should -Match 'Remove:'
        $text | Should -Match 'Rewrite:'
        $text | Should -Match 'Keep:'
        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'VERSION') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'CHANGELOG.md') | Should -BeTrue
    }

    It 'defines the required remote-freshness stop conditions before cleanup can apply changes' {
        $content = Get-Content -Raw -LiteralPath $script:ScriptPath

        $content | Should -Match 'function Assert-RemoteFreshness'
        $content | Should -Match 'origin is not configured'
        $content | Should -Match 'no upstream'
        $content | Should -Match 'behind its upstream'
        $content | Should -Match 'has diverged from its upstream'
        $content | Should -Match 'latest origin/main'
        $content | Should -Match 'if \(\$Apply\) \{\s*Assert-RemoteFreshness'
    }

    It 'removes template-only files and rewrites docs in script mode' {
        & Invoke-CleanupScript -RepoPath $script:DownstreamRepo -ExtraArguments @('-Apply') | Out-Null

        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'VERSION') | Should -BeFalse
        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'CHANGELOG.md') | Should -BeFalse
        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'src/TemplateModule.psd1') | Should -BeFalse
        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'src/TemplateModule.psm1') | Should -BeFalse
        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath '.codex/skills/runtime-policy-update') | Should -BeFalse
        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath '.codex/skills/template-version-release') | Should -BeFalse

        $readme = Get-Content -Raw -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'README.md')
        $readme | Should -Match '# winget-pwsh-automation'
        $readme | Should -Match 'template-0\.11\.0-blue'
        $readme | Should -Match '## Portfolio Context'
        $readme | Should -Match '## Template Versioning'
        $readme | Should -Match 'Quick navigation:'

        $agents = Get-Content -Raw -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'AGENTS.md')
        $agents | Should -Match 'downstream-repo-cleanup'
        $agents | Should -Not -Match 'template-version-release'
    }

    It 'requires ModuleName for module cleanup' {
        {
            & Invoke-CleanupScript -RepoPath $script:DownstreamRepo -ExtraArguments @('-ProjectType', 'module')
        } | Should -Throw -ExpectedMessage '*ModuleName is required*'
    }

    It 'renames module files and updates placeholder metadata in module mode' {
        & Invoke-CleanupScript -RepoPath $script:DownstreamRepo -ExtraArguments @('-ProjectType', 'module', '-ModuleName', 'WingetAutomation', '-Apply') | Out-Null

        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'src/WingetAutomation.psd1') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'src/WingetAutomation.psm1') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'src/TemplateModule.psd1') | Should -BeFalse

        $manifest = Get-Content -Raw -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'src/WingetAutomation.psd1')
        $manifest | Should -Match "RootModule = 'WingetAutomation\.psm1'"
        $manifest | Should -Match "Author = 'Repository Maintainer'"
        $manifest | Should -Match "Description = 'PowerShell module for winget-pwsh-automation\. Update metadata before release\.'"

        $moduleContent = Get-Content -Raw -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'src/WingetAutomation.psm1')
        $moduleContent | Should -Not -Match 'TemplateModule'
    }

    It 'preserves downstream guidance sync assets and runtime policy infrastructure' {
        & Invoke-CleanupScript -RepoPath $script:DownstreamRepo -ExtraArguments @('-Apply') | Out-Null

        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath '.codex/skills/downstream-guidance-sync/SKILL.md') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath '.codex/skills/downstream-repo-cleanup/SKILL.md') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath '.codex/skills/readme-alignment/SKILL.md') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'scripts/Invoke-ReadmeAlignment.ps1') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'scripts/Invoke-MarkdownValidation.ps1') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'eng/runtime-policy.json') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'scripts/Update-GeneratedMarkdown.ps1') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'templates/downstream/README.md') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'scripts/Invoke-RepoChecks.ps1') | Should -BeTrue
    }

    It 'rewrites docs and copilot instructions into downstream form' {
        & Invoke-CleanupScript -RepoPath $script:DownstreamRepo -ExtraArguments @('-Apply') | Out-Null

        $copilot = Get-Content -Raw -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath '.github/copilot-instructions.md')
        $copilot | Should -Match 'created from the pwsh-dev-template GitHub template'
        $copilot | Should -Match 'downstream-repo-cleanup'
        $copilot | Should -Match 'readme-alignment'
        $copilot | Should -Not -Match 'runtime-policy-update'
        $copilot | Should -Not -Match 'template-version-release'

        $agents = Get-Content -Raw -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'AGENTS.md')
        $agents | Should -Match '## Guidance Layers'
        $agents | Should -Match 'powershell-authoring'
        $agents | Should -Match 'Mandatory Freshness Gate'
        $agents | Should -Not -Match 'primary AI guidance'

        $workflows = Get-Content -Raw -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'docs/agent-workflows.md')
        $workflows | Should -Match 'Downstream repo cleanup'
        $workflows | Should -Match 'Downstream guidance sync'
        $workflows | Should -Match 'README alignment'
        $workflows | Should -Match 'powershell-testing-review'
        $workflows | Should -Match 'mandatory remote-freshness preflight'
        $workflows | Should -Not -Match 'Runtime policy update'

        $decisionsReadme = Get-Content -Raw -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'docs/decisions/README.md')
        $decisionsReadme | Should -Match 'durable repository decisions'
        $decisionsReadme | Should -Not -Match 'durable template decisions'
    }

    It 'preserves the README template version badge when already present' {
        & Invoke-CleanupScript -RepoPath $script:DownstreamRepo -ExtraArguments @('-Apply') | Out-Null

        $readme = Get-Content -Raw -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'README.md')
        $readme | Should -Match '!\[Template Version\]\(https://img\.shields\.io/badge/template-0\.11\.0-blue\)'
    }

    It 'inserts the README template version badge when it is missing' {
        Remove-Item -LiteralPath $script:DownstreamRepo -Recurse -Force
        New-TemplateLikeDownstreamRepo -Path $script:DownstreamRepo -OmitReadmeBadge

        & Invoke-CleanupScript -RepoPath $script:DownstreamRepo -ExtraArguments @('-Apply') | Out-Null

        $readme = Get-Content -Raw -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'README.md')
        $readme | Should -Match '!\[Template Version\]\(https://img\.shields\.io/badge/template-0\.11\.0-blue\)'
    }

    It 'uses the repo name in downstream text rewrites' {
        & Invoke-CleanupScript -RepoPath $script:DownstreamRepo -ExtraArguments @('-Apply') | Out-Null

        $readme = Get-Content -Raw -LiteralPath (Join-Path -Path $script:DownstreamRepo -ChildPath 'README.md')
        $readme | Should -Match '# winget-pwsh-automation'
        $readme | Should -Match 'Add a concise repository summary that explains what this project does and why it exists.'
    }

    It 'produces a downstream README that is compatible with generated Markdown validation' {
        & Invoke-CleanupScript -RepoPath $script:DownstreamRepo -ExtraArguments @('-Apply') | Out-Null

        $scriptPath = Join-Path -Path $script:DownstreamRepo -ChildPath 'scripts/Update-GeneratedMarkdown.ps1'
        $output = & pwsh -NoProfile -File $scriptPath -Check 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw ($output -join [Environment]::NewLine)
        }
    }

    It 'stops when the repo has moved beyond the immediate cleanup window' {
        $customSourcePath = Join-Path -Path $script:DownstreamRepo -ChildPath 'src/Public/Get-WingetPackage.ps1'
        [System.IO.File]::WriteAllText($customSourcePath, 'function Get-WingetPackage {}', [System.Text.UTF8Encoding]::new($false))
        & git -C $script:DownstreamRepo add src/Public/Get-WingetPackage.ps1 | Out-Null
        & git -C $script:DownstreamRepo commit -m 'add custom source' | Out-Null

        {
            & Invoke-CleanupScript -RepoPath $script:DownstreamRepo
        } | Should -Throw -ExpectedMessage '*immediate post-create window*'
    }

    It 'returns parseable JSON output' {
        $json = & Invoke-CleanupScript -RepoPath $script:DownstreamRepo -ExtraArguments @('-OutputFormat', 'Json')
        $report = $json | ConvertFrom-Json

        $report.RepositoryName | Should -Be 'winget-pwsh-automation'
        $report.ProjectType | Should -Be 'script'
        $report.TemplateVersion | Should -Be '0.11.0'
        $report.Report.Action | Should -Contain 'Remove'
        $report.Report.Action | Should -Contain 'Rewrite'
    }
}
