# Providing Instructions To GitHup Copilot

## .github/Copilot-Instructions.md

- .github/Copilot-Instructions.md is automatically loaded
- This file is global, always-on instructions for the entire repo

Copilot loads it:

- for every suggestion
- for every PR review
- for everything you type
- for every context

## .github/Instructions

- optional
- domain specific
- loaded when relevant
- blended with global instructions

Copilot discovers them automatically based on:

- file names
- folder names
- content
- language
- context

## Don't

Don't reference these files from Copilot-Instructions.md thinking that this will guide Copilot's actions, because it just doesn't work like that

## Do

Do reference these files from Copilot-Instructions.md when you want humans to understand your repo's governance structure

Example:

``` Markdown
## Additional Domain Instructions
This file defines global rules. Domain-specific rules live in:

- .github/instructions/powershell.instructions.md
- .github/instructions/pester.instructions.md
- .github/instructions/module-structure.instructions.md
```

## Example Instrucionts folder contents

- .github/instructions/powershell.instructions.md
- .github/instructions/pester.instructions.md
- .github/instructions/module-structure.instructions.md
- .github/instructions/governance.instructions.md
- .github/instructions/identity-governance.instructions.md
- .github/instructions/automation-first.instructions.md
