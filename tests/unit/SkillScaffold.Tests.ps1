Describe 'Repo-local skills' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..\..')).Path
        $script:ChangeDeliverySkillPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/change-delivery-workflow/SKILL.md'
        $script:ChangeDeliverySkillMetadataPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/change-delivery-workflow/agents/openai.yaml'
        $script:CleanupSkillPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/downstream-repo-cleanup/SKILL.md'
        $script:CleanupSkillMetadataPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/downstream-repo-cleanup/agents/openai.yaml'
        $script:SkillPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/downstream-guidance-sync/SKILL.md'
        $script:SkillMetadataPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/downstream-guidance-sync/agents/openai.yaml'
        $script:ReadmeAlignmentSkillPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/readme-alignment/SKILL.md'
        $script:ReadmeAlignmentSkillMetadataPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/readme-alignment/agents/openai.yaml'
        $script:RuntimeSkillPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/runtime-policy-update/SKILL.md'
        $script:RuntimeSkillMetadataPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/runtime-policy-update/agents/openai.yaml'
        $script:VersionSkillPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/template-version-release/SKILL.md'
        $script:VersionSkillMetadataPath = Join-Path -Path $script:RepoRoot -ChildPath '.codex/skills/template-version-release/agents/openai.yaml'
        $script:CleanupScriptPath = Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Initialize-DownstreamRepo.ps1'
        $script:SyncScriptPath = Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Invoke-TemplateGuidanceSync.ps1'
        $script:ReadmeAlignmentScriptPath = Join-Path -Path $script:RepoRoot -ChildPath 'scripts/Invoke-ReadmeAlignment.ps1'
        $script:RuntimePolicyPath = Join-Path -Path $script:RepoRoot -ChildPath 'eng/runtime-policy.json'
        $script:AgentWorkflowsPath = Join-Path -Path $script:RepoRoot -ChildPath 'docs/agent-workflows.md'
    }

    It 'includes the change delivery workflow skill' {
        Test-Path -LiteralPath $script:ChangeDeliverySkillPath -PathType Leaf | Should -BeTrue
        Test-Path -LiteralPath $script:ChangeDeliverySkillMetadataPath -PathType Leaf | Should -BeTrue
    }

    It 'uses valid required change delivery skill frontmatter' {
        $content = Get-Content -Raw -LiteralPath $script:ChangeDeliverySkillPath

        $content | Should -Match '^---\s*\r?\nname: change-delivery-workflow\r?\n'
        $content | Should -Match '\r?\ndescription: .+change.+workflow.+\r?\n---'
    }

    It 'documents sandbox recovery, branch discipline, and changelog expectations' {
        $content = Get-Content -Raw -LiteralPath $script:ChangeDeliverySkillPath

        $content | Should -Match 'helper_sid_resolve_failed'
        $content | Should -Match 'CodexSandboxOffline'
        $content | Should -Match 'sandbox_permissions: require_escalated'
        $content | Should -Match 'CHANGELOG\.md'
        $content | Should -Match '## Unreleased'
        $content | Should -Match 'non-main branch'
        $content | Should -Match 'ready PR'
        $content | Should -Match 'Conventional Commit'
    }

    It 'uses valid change delivery skill UI metadata with an explicit skill prompt' {
        $content = Get-Content -Raw -LiteralPath $script:ChangeDeliverySkillMetadataPath

        $content | Should -Match 'display_name: "Change Delivery Workflow"'
        $content | Should -Match 'short_description: "Deliver ordinary repo changes with branch, changelog, PR, and release discipline"'
        $content | Should -Match 'default_prompt: "Use \$change-delivery-workflow'
    }

    It 'makes the change delivery workflow discoverable from repository agent instructions' {
        $readmeContent = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'README.md')
        $agentsContent = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'AGENTS.md')
        $copilotContent = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath '.github/copilot-instructions.md')
        $workflowContent = Get-Content -Raw -LiteralPath $script:AgentWorkflowsPath

        $readmeContent | Should -Match '\.codex/skills/change-delivery-workflow/SKILL\.md'
        $agentsContent | Should -Match '\.codex/skills/change-delivery-workflow/SKILL\.md'
        $copilotContent | Should -Match '\.codex/skills/change-delivery-workflow/SKILL\.md'
        $workflowContent | Should -Match '\.codex/skills/change-delivery-workflow/SKILL\.md'
    }
    It 'includes the downstream repo cleanup skill' {
        Test-Path -LiteralPath $script:CleanupSkillPath -PathType Leaf | Should -BeTrue
        Test-Path -LiteralPath $script:CleanupSkillMetadataPath -PathType Leaf | Should -BeTrue
    }

    It 'uses valid required cleanup skill frontmatter' {
        $content = Get-Content -Raw -LiteralPath $script:CleanupSkillPath

        $content | Should -Match '^---\s*\r?\nname: downstream-repo-cleanup\r?\n'
        $content | Should -Match '\r?\ndescription: .+downstream.+cleanup.+\r?\n---'
    }

    It 'references the authoritative cleanup script and README badge contract' {
        $content = Get-Content -Raw -LiteralPath $script:CleanupSkillPath

        $content | Should -Match 'Initialize-DownstreamRepo\.ps1'
        $content | Should -Match 'README template version badge'
        $content | Should -Match 'immediate post-create'
        Test-Path -LiteralPath $script:CleanupScriptPath -PathType Leaf | Should -BeTrue
    }

    It 'uses valid cleanup skill UI metadata with an explicit skill prompt' {
        $content = Get-Content -Raw -LiteralPath $script:CleanupSkillMetadataPath

        $content | Should -Match 'display_name: "Downstream Repo Cleanup"'
        $content | Should -Match 'short_description: "Normalize a new downstream repo"'
        $content | Should -Match 'default_prompt: "Use \$downstream-repo-cleanup'
    }

    It 'makes the cleanup skill discoverable from repository agent instructions' {
        $readmeContent = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'README.md')
        $agentsContent = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'AGENTS.md')
        $copilotContent = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath '.github/copilot-instructions.md')
        $workflowContent = Get-Content -Raw -LiteralPath $script:AgentWorkflowsPath

        $readmeContent | Should -Match 'Initialize-DownstreamRepo\.ps1'
        $readmeContent | Should -Match 'template version badge'
        $agentsContent | Should -Match '\.codex/skills/downstream-repo-cleanup/SKILL\.md'
        $agentsContent | Should -Match 'Initialize-DownstreamRepo\.ps1'
        $copilotContent | Should -Match '\.codex/skills/downstream-repo-cleanup/SKILL\.md'
        $copilotContent | Should -Match 'Initialize-DownstreamRepo\.ps1'
        $workflowContent | Should -Match '\.codex/skills/change-delivery-workflow/SKILL\.md'
        $workflowContent | Should -Match '\.codex/skills/downstream-repo-cleanup/SKILL\.md'
        $workflowContent | Should -Match 'scripts/Initialize-DownstreamRepo\.ps1'
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

    It 'references the authoritative sync script and cleanup asset delivery path' {
        $content = Get-Content -Raw -LiteralPath $script:SkillPath

        $content | Should -Match 'Invoke-TemplateGuidanceSync\.ps1'
        $content | Should -Match 'Initialize-DownstreamRepo\.ps1'
        $content | Should -Match 'does not perform cleanup itself'
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
        $content | Should -Match 'docs/decisions/README\.md'
        $content | Should -Match 'scripts/Initialize-DownstreamRepo\.ps1'
        $content | Should -Match '\.codex/skills/downstream-repo-cleanup/'
        $content | Should -Match '\.codex/skills/readme-alignment/'
        $content | Should -Match 'does not perform cleanup or README alignment itself'
        $content | Should -Match 'must not update downstream source, tests, Pester configuration, PSScriptAnalyzer settings, CI workflows, Dev Container files, module manifests, scaffolds other than the cleanup and README workflow assets, or numbered project-specific ADRs'
    }

    It 'uses valid skill UI metadata with an explicit skill prompt' {
        $content = Get-Content -Raw -LiteralPath $script:SkillMetadataPath

        $content | Should -Match 'display_name: "Downstream Guidance Sync"'
        $content | Should -Match 'short_description: "Sync template guidance and cleanup assets into downstream repos"'
        $content | Should -Match 'default_prompt: "Use \$downstream-guidance-sync'
        $content | Should -Match 'cleanup workflow assets'
    }

    It 'is discoverable from repository agent instructions' {
        $agentsPath = Join-Path -Path $script:RepoRoot -ChildPath 'AGENTS.md'
        $copilotPath = Join-Path -Path $script:RepoRoot -ChildPath '.github/copilot-instructions.md'
        $agentsContent = Get-Content -Raw -LiteralPath $agentsPath
        $copilotContent = Get-Content -Raw -LiteralPath $copilotPath

        $agentsContent | Should -Match '\.codex/skills/downstream-guidance-sync/SKILL\.md'
        $agentsContent | Should -Match 'Invoke-TemplateGuidanceSync\.ps1'
        $agentsContent | Should -Match 'Initialize-DownstreamRepo\.ps1'
        $copilotContent | Should -Match '\.codex/skills/downstream-guidance-sync/SKILL\.md'
        $copilotContent | Should -Match 'Invoke-TemplateGuidanceSync\.ps1'
        $copilotContent | Should -Match 'Initialize-DownstreamRepo\.ps1'
    }

    It 'includes the README alignment skill' {
        Test-Path -LiteralPath $script:ReadmeAlignmentSkillPath -PathType Leaf | Should -BeTrue
        Test-Path -LiteralPath $script:ReadmeAlignmentSkillMetadataPath -PathType Leaf | Should -BeTrue
    }

    It 'uses valid required README alignment skill frontmatter' {
        $content = Get-Content -Raw -LiteralPath $script:ReadmeAlignmentSkillPath

        $content | Should -Match '^---\s*\r?\nname: readme-alignment\r?\n'
        $content | Should -Match '\r?\ndescription: .+README.+align.+\r?\n---'
    }

    It 'references the authoritative README alignment script and shared skeleton boundary' {
        $content = Get-Content -Raw -LiteralPath $script:ReadmeAlignmentSkillPath

        $content | Should -Match 'Invoke-ReadmeAlignment\.ps1'
        $content | Should -Match 'template-derived downstream repositories'
        $content | Should -Match 'Portfolio Context'
        $content | Should -Match 'Template Versioning'
        Test-Path -LiteralPath $script:ReadmeAlignmentScriptPath -PathType Leaf | Should -BeTrue
    }

    It 'uses valid README alignment skill UI metadata with an explicit skill prompt' {
        $content = Get-Content -Raw -LiteralPath $script:ReadmeAlignmentSkillMetadataPath

        $content | Should -Match 'display_name: "README Alignment"'
        $content | Should -Match 'short_description: "Align a downstream README to the shared portfolio skeleton"'
        $content | Should -Match 'default_prompt: "Use \$readme-alignment'
    }

    It 'makes the README alignment skill discoverable from repository agent instructions' {
        $readmeContent = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'README.md')
        $agentsContent = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'AGENTS.md')
        $copilotContent = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath '.github/copilot-instructions.md')
        $workflowContent = Get-Content -Raw -LiteralPath $script:AgentWorkflowsPath

        $readmeContent | Should -Match '\.codex/skills/readme-alignment/SKILL\.md'
        $agentsContent | Should -Match '\.codex/skills/readme-alignment/SKILL\.md'
        $copilotContent | Should -Match '\.codex/skills/readme-alignment/SKILL\.md'
        $workflowContent | Should -Match '\.codex/skills/readme-alignment/SKILL\.md'
        $workflowContent | Should -Match 'scripts/Invoke-ReadmeAlignment\.ps1'
        $workflowContent | Should -Match 'templates/downstream/README\.md'
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
        $content | Should -Match 'git tag vX.Y.Z'
        $content | Should -Match 'verified'
        $content | Should -Match 'GitHub Release'
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
        $readmeContent | Should -Match 'GitHub Release'
        $evolutionContent | Should -Match 'GitHub Release'
        $agentsContent | Should -Match 'GitHub Release'
        $copilotContent | Should -Match 'GitHub Release'
    }

    It 'documents repo-local agent workflows for human discovery' {
        Test-Path -LiteralPath $script:AgentWorkflowsPath -PathType Leaf | Should -BeTrue

        $workflowContent = Get-Content -Raw -LiteralPath $script:AgentWorkflowsPath
        $readmeContent = Get-Content -Raw -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath 'README.md')

        $workflowContent | Should -Match '\.codex/skills/change-delivery-workflow/SKILL\.md'
        $workflowContent | Should -Match '\.codex/skills/downstream-repo-cleanup/SKILL\.md'
        $workflowContent | Should -Match 'scripts/Initialize-DownstreamRepo\.ps1'
        $workflowContent | Should -Match '\.codex/skills/downstream-guidance-sync/SKILL\.md'
        $workflowContent | Should -Match 'scripts/Invoke-TemplateGuidanceSync\.ps1'
        $workflowContent | Should -Match '\.codex/skills/readme-alignment/SKILL\.md'
        $workflowContent | Should -Match 'scripts/Invoke-ReadmeAlignment\.ps1'
        $workflowContent | Should -Match 'templates/downstream/README\.md'
        $workflowContent | Should -Match '\.codex/skills/runtime-policy-update/SKILL\.md'
        $workflowContent | Should -Match 'eng/runtime-policy\.json'
        $workflowContent | Should -Match '\.codex/skills/template-version-release/SKILL\.md'
        $workflowContent | Should -Match 'scripts/Test-TemplateVersion\.ps1'
        $workflowContent | Should -Match 'GitHub Releases'
        $workflowContent | Should -Match 'tests/unit/SkillScaffold\.Tests\.ps1'
        $readmeContent | Should -Match 'docs/agent-workflows\.md'
    }

    It 'documents success criteria for each repo-local workflow' {
        $changeDeliveryContent = Get-Content -Raw -LiteralPath $script:ChangeDeliverySkillPath
        $cleanupContent = Get-Content -Raw -LiteralPath $script:CleanupSkillPath
        $syncContent = Get-Content -Raw -LiteralPath $script:SkillPath
        $readmeAlignmentContent = Get-Content -Raw -LiteralPath $script:ReadmeAlignmentSkillPath
        $runtimeContent = Get-Content -Raw -LiteralPath $script:RuntimeSkillPath
        $versionContent = Get-Content -Raw -LiteralPath $script:VersionSkillPath

        $changeDeliveryContent | Should -Match '## Success Criteria'
        $changeDeliveryContent | Should -Match 'CHANGELOG\.md'
        $changeDeliveryContent | Should -Match 'non-main branch'
        $changeDeliveryContent | Should -Match 'ready PR'
        $changeDeliveryContent | Should -Match 'post-merge cleanup'

        $cleanupContent | Should -Match '## Success Criteria'
        $cleanupContent | Should -Match 'README template version badge'
        $cleanupContent | Should -Match 'project-specific work'
        $cleanupContent | Should -Match 'downstream validation'

        $syncContent | Should -Match '## Success Criteria'
        $syncContent | Should -Match 'audit output'
        $syncContent | Should -Match 'non-main downstream branch'
        $syncContent | Should -Match 'sync allowlist'
        $syncContent | Should -Match 'cleanup-asset delivery'
        $syncContent | Should -Match 'validation result'

        $readmeAlignmentContent | Should -Match '## Success Criteria'
        $readmeAlignmentContent | Should -Match 'shared skeleton order'
        $readmeAlignmentContent | Should -Match 'Portfolio Context'
        $readmeAlignmentContent | Should -Match 'Template Versioning'
        $readmeAlignmentContent | Should -Match 'downstream validation'

        $runtimeContent | Should -Match '## Success Criteria'
        $runtimeContent | Should -Match 'eng/runtime-policy\.json'
        $runtimeContent | Should -Match 'generated Markdown agree with the policy'
        $runtimeContent | Should -Match 'Update-GeneratedMarkdown\.ps1 -Check'
        $runtimeContent | Should -Match 'Invoke-RepoChecks\.ps1 -IncludeTemplates'

        $versionContent | Should -Match '## Success Criteria'
        $versionContent | Should -Match 'VERSION'
        $versionContent | Should -Match 'README template badge'
        $versionContent | Should -Match 'CHANGELOG\.md'
        $versionContent | Should -Match 'vX\.Y\.Z'
        $versionContent | Should -Match 'lightweight'
        $versionContent | Should -Match 'Test-TemplateVersion\.ps1 -CheckTag'
        $versionContent | Should -Match 'verified'
        $versionContent | Should -Match 'GitHub Release exists'
    }

    It 'documents rationale for workflow boundaries' {
        $changeDeliveryContent = Get-Content -Raw -LiteralPath $script:ChangeDeliverySkillPath
        $cleanupContent = Get-Content -Raw -LiteralPath $script:CleanupSkillPath
        $syncContent = Get-Content -Raw -LiteralPath $script:SkillPath
        $readmeAlignmentContent = Get-Content -Raw -LiteralPath $script:ReadmeAlignmentSkillPath
        $runtimeContent = Get-Content -Raw -LiteralPath $script:RuntimeSkillPath
        $versionContent = Get-Content -Raw -LiteralPath $script:VersionSkillPath

        $changeDeliveryContent | Should -Match '## Why This Exists'
        $changeDeliveryContent | Should -Match 'helper_sid_resolve_failed'
        $changeDeliveryContent | Should -Match 'Windows sandbox'
        $changeDeliveryContent | Should -Match 'release/version contract'
        $changeDeliveryContent | Should -Match 'ordinary repository work'

        $cleanupContent | Should -Match '## Why This Exists'
        $cleanupContent | Should -Match 'template-maintainer artifacts'
        $cleanupContent | Should -Match 'README template version badge'
        $cleanupContent | Should -Match 'first-run cleanup'

        $syncContent | Should -Match '## Why This Exists'
        $syncContent | Should -Match 'independent projects'
        $syncContent | Should -Match 'AI guidance'
        $syncContent | Should -Match 'cleanup script'
        $syncContent | Should -Match 'runtime-policy README-generation assets'
        $syncContent | Should -Match 'project-owned'
        $syncContent | Should -Match 'should not be clobbered'

        $readmeAlignmentContent | Should -Match '## Why This Exists'
        $readmeAlignmentContent | Should -Match 'shared skeleton'
        $readmeAlignmentContent | Should -Match 'generator-driven'
        $readmeAlignmentContent | Should -Match 'repo-specific sections'

        $runtimeContent | Should -Match '## Why This Exists'
        $runtimeContent | Should -Match 'Runtime and tooling pins'
        $runtimeContent | Should -Match 'eng/runtime-policy\.json'
        $runtimeContent | Should -Match 'Generated Markdown'
        $runtimeContent | Should -Match 'repeatable, reviewable'

        $versionContent | Should -Not -Match '## Why This Exists'
    }
}
