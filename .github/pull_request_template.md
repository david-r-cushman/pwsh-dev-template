## Summary

<!-- What changed and why? Keep it brief and concrete. -->

## Checklist

- [ ] I ran local checks: `pwsh -NoProfile -File .\\scripts\\Invoke-RepoChecks.ps1`
- [ ] New/changed behavior is covered by Pester tests (or tests are not applicable and I explained why)
- [ ] State-changing functions use `SupportsShouldProcess` and guard mutations with `if ($PSCmdlet.ShouldProcess(...))`
- [ ] Output contracts are stable and return structured objects (not formatted text)
- [ ] No secrets, tokens, or credentials are logged or committed
- [ ] Documentation is updated where behavior or usage changed

## Notes for reviewers

<!-- Risks, tradeoffs, compatibility notes, or follow-up work. -->

