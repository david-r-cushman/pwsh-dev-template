---
applyTo: "**/*.md"
---

# Markdown Rules

- Keep Markdown claims factual, concise, and aligned with implemented behavior.
- Preserve generated Markdown blocks; change their source and run the generator instead of editing their contents.
- Use blank lines around headings and lists. Run `scripts/Invoke-MarkdownValidation.ps1 -Path <markdown-path>` after editing Markdown.
- Record durable template decisions in `docs/decisions/`; keep implementation plans in pull-request discussion.
