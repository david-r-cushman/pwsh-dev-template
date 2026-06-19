Describe 'Repo-local skills' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..\..')).Path
        $script:SkillPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/downstream-guidance-sync/SKILL.md'
        $script:SkillMetadataPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/downstream-guidance-sync/agents/openai.yaml'
        $script:RuntimeSkillPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/runtime-policy-update/SKILL.md'
        $script:RuntimeSkillMetadataPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/runtime-policy-update/agents/openai.yaml'
        $script:SyncScriptPath = Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Invoke-TemplateGuidanceSync.ps1'
        $script:RuntimePolicyPath = Join-Path -Path $script:RepoRoot -ChildPath 'eng/runtime-policy.json'
    }

    It 'includes the downstream guidance sync skill' {
        Test-Path -LiteralPath $script:SkillPath -PathType Leaf | Should -BeTrue
        Test-Path -LiteralPath $script:SkillMetadataPath -PathType Leaf | Should -BeTrue
    }

    It 'uses valid required skill frontmatter' {
        $content = Get-Content -Raw -LiteralPath $script:SkillPath

        $content | Should -Match '^---\s*\r?\nname: downstream-guidance-sync\r?\n'
        $content | Should -Match '\r?\ndescription: .+downstream.+sync.+\r?\n---'
    }

    It 'references the authoritative sync script' {
        $content = Get-Content -Raw -LiteralPath $script:SkillPath

        $content | Should -Match 'Invoke-TemplateGuidanceSync\.ps1'
        Test-Path -LiteralPath $script:SyncScriptPath -PathType Leaf | Should -BeTrue
    }

    It 'documents branch, audit, apply, diff, and validation workflow expectations' {
        $content = Get-Content -Raw -LiteralPath $script:SkillPath

        $content | Should -Match 'audit mode first'
        $content | Should -Match 'non-main branch'
        $content | Should -Match '-Apply'
        $content | Should -Match 'Inspect the downstream diff'
        $content | Should -Match 'Run downstream validation'
    }

    It 'documents the downstream sync boundary' {
        $content = Get-Content -Raw -LiteralPath $script:SkillPath

        $content | Should -Match 'AGENTS\.md'
        $content | Should -Match '\.github/copilot-instructions\.md'
        $content | Should -Match 'README template-version badge'
        $content | Should -Match 'must not update downstream source, tests, Pester configuration, PSScriptAnalyzer settings, CI workflows, Dev Container files, runtime policy, module manifests, or scaffolds'
    }

    It 'uses valid skill UI metadata with an explicit skill prompt' {
        $content = Get-Content -Raw -LiteralPath $script:SkillMetadataPath

        $content | Should -Match 'display_name: "Downstream Guidance Sync"'
        $content | Should -Match 'short_description: "Sync template AI guidance into downstream repos"'
        $content | Should -Match 'default_prompt: "Use \$downstream-guidance-sync'
    }

    It 'is discoverable from repository agent instructions' {
        $agentsPath = Join-Path -Path $script:RepoRoot -ChildPath 'AGENTS.md'
        $copilotPath = Join-Path -Path $script:RepoRoot -ChildPath '.github/copilot-instructions.md'
        $agentsContent = Get-Content -Raw -LiteralPath $agentsPath
        $copilotContent = Get-Content -Raw -LiteralPath $copilotPath

        $agentsContent | Should -Match '\.codex/skills/downstream-guidance-sync/SKILL\.md'
        $agentsContent | Should -Match 'Invoke-TemplateGuidanceSync\.ps1'
        $copilotContent | Should -Match '\.codex/skills/downstream-guidance-sync/SKILL\.md'
        $copilotContent | Should -Match 'Invoke-TemplateGuidanceSync\.ps1'
    }

    It 'includes the runtime policy update skill' {
        Test-Path -LiteralPath $script:RuntimeSkillPath -PathType Leaf | Should -BeTrue
        Test-Path -LiteralPath $script:RuntimeSkillMetadataPath -PathType Leaf | Should -BeTrue
    }

    It 'uses valid required runtime skill frontmatter' {
        $content = Get-Content -Raw -LiteralPath $script:RuntimeSkillPath

        $content | Should -Match '^---\s*\r?\nname: runtime-policy-update\r?\n'
        $content | Should -Match '\r?\ndescription: .+runtime.+policy.+\r?\n---'
    }

    It 'references the runtime policy source of truth and validation scripts' {
        $content = Get-Content -Raw -LiteralPath $script:RuntimeSkillPath

        $content | Should -Match 'eng/runtime-policy\.json'
        $content | Should -Match 'Update-GeneratedMarkdown\.ps1'
        $content | Should -Match 'Test-VersionPolicy\.ps1'
        $content | Should -Match 'Invoke-RepoChecks\.ps1'
        Test-Path -LiteralPath $script:RuntimePolicyPath -PathType Leaf | Should -BeTrue
    }

    It 'documents generated Markdown and downstream boundaries for runtime updates' {
        $content = Get-Content -Raw -LiteralPath $script:RuntimeSkillPath

        $content | Should -Match 'Do not edit generated Markdown block contents by hand'
        $content | Should -Match 'downstream repositories'
        $content | Should -Match 'template repository'
    }

    It 'uses valid runtime skill UI metadata with an explicit skill prompt' {
        $content = Get-Content -Raw -LiteralPath $script:RuntimeSkillMetadataPath

        $content | Should -Match 'display_name: "Runtime Policy Update"'
        $content | Should -Match 'short_description: "Update template runtime and tooling pins"'
        $content | Should -Match 'default_prompt: "Use \$runtime-policy-update'
    }

    It 'makes the runtime skill discoverable from repository agent instructions' {
        $agentsPath = Join-Path -Path $script:RepoRoot -ChildPath 'AGENTS.md'
        $copilotPath = Join-Path -Path $script:RepoRoot -ChildPath '.github/copilot-instructions.md'
        $agentsContent = Get-Content -Raw -LiteralPath $agentsPath
        $copilotContent = Get-Content -Raw -LiteralPath $copilotPath

        $agentsContent | Should -Match '\.codex/skills/runtime-policy-update/SKILL\.md'
        $agentsContent | Should -Match 'eng/runtime-policy\.json'
        $copilotContent | Should -Match '\.codex/skills/runtime-policy-update/SKILL\.md'
        $copilotContent | Should -Match 'eng/runtime-policy\.json'
    }
}
