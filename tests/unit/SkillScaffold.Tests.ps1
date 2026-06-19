Describe 'Repo-local skills' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..\..')).Path
        $script:SkillPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/downstream-guidance-sync/SKILL.md'
        $script:SkillMetadataPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/downstream-guidance-sync/agents/openai.yaml'
        $script:RuntimeSkillPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/runtime-policy-update/SKILL.md'
        $script:RuntimeSkillMetadataPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/runtime-policy-update/agents/openai.yaml'
        $script:VersionSkillPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/template-version-release/SKILL.md'
        $script:VersionSkillMetadataPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/template-version-release/agents/openai.yaml'
        $script:SyncScriptPath = Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Invoke-TemplateGuidanceSync.ps1'
        $script:RuntimePolicyPath = Join-Path -Path $script:RepoRoot -ChildPath 'eng/runtime-policy.json'
        $script:AgentWorkflowsPath = Join-Path -Path $script:RepoRoot -ChildPath 'docs/agent-workflows.md'
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

    It 'includes the template version release skill' {
        Test-Path -LiteralPath $script:VersionSkillPath -PathType Leaf | Should -BeTrue
        Test-Path -LiteralPath $script:VersionSkillMetadataPath -PathType Leaf | Should -BeTrue
    }

    It 'uses valid required template version skill frontmatter' {
        $content = Get-Content -Raw -LiteralPath $script:VersionSkillPath

        $content | Should -Match '^---\s*\r?\nname: template-version-release\r?\n'
        $content | Should -Match '\r?\ndescription: .+version.+release.+\r?\n---'
    }

    It 'references release metadata surfaces and tag workflow' {
        $content = Get-Content -Raw -LiteralPath $script:VersionSkillPath

        $content | Should -Match 'VERSION'
        $content | Should -Match 'CHANGELOG\.md'
        $content | Should -Match 'README template badge'
        $content | Should -Match 'Test-TemplateVersion\.ps1'
        $content | Should -Match 'docs/template-evolution\.md'
        $content | Should -Match 'README\.md'
        $content | Should -Match 'vX\.Y\.Z'
    }

    It 'uses valid template version skill UI metadata with an explicit skill prompt' {
        $content = Get-Content -Raw -LiteralPath $script:VersionSkillMetadataPath

        $content | Should -Match 'display_name: "Template Version Release"'
        $content | Should -Match 'short_description: "Manage template version releases"'
        $content | Should -Match 'default_prompt: "Use \$template-version-release'
    }

    It 'documents the version skill in repository docs and agent instructions' {
        $readmeContent = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'README.md')
        $evolutionContent = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'docs/template-evolution.md')
        $agentsContent = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'AGENTS.md')
        $copilotContent = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath '.github/copilot-instructions.md')

        $readmeContent | Should -Match '\.codex/skills/template-version-release/SKILL\.md'
        $evolutionContent | Should -Match '\.codex/skills/template-version-release/SKILL\.md'
        $agentsContent | Should -Match '\.codex/skills/template-version-release/SKILL\.md'
        $copilotContent | Should -Match '\.codex/skills/template-version-release/SKILL\.md'
    }

    It 'documents repo-local agent workflows for human discovery' {
        Test-Path -LiteralPath $script:AgentWorkflowsPath -PathType Leaf | Should -BeTrue

        $workflowContent = Get-Content -Raw -LiteralPath $script:AgentWorkflowsPath
        $readmeContent = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'README.md')

        $workflowContent | Should -Match '\.codex/skills/downstream-guidance-sync/SKILL\.md'
        $workflowContent | Should -Match 'scripts/Invoke-TemplateGuidanceSync\.ps1'
        $workflowContent | Should -Match '\.codex/skills/runtime-policy-update/SKILL\.md'
        $workflowContent | Should -Match 'eng/runtime-policy\.json'
        $workflowContent | Should -Match '\.codex/skills/template-version-release/SKILL\.md'
        $workflowContent | Should -Match 'scripts/Test-TemplateVersion\.ps1'
        $workflowContent | Should -Match 'tests/unit/SkillScaffold\.Tests\.ps1'
        $readmeContent | Should -Match 'docs/agent-workflows\.md'
    }
}
