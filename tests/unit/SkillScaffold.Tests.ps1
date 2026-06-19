Describe 'Repo-local skills' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..\..')).Path
        $script:SkillPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/downstream-guidance-sync/SKILL.md'
        $script:SkillMetadataPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/downstream-guidance-sync/agents/openai.yaml'
        $script:SyncScriptPath = Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Invoke-TemplateGuidanceSync.ps1'
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
}
