---
name: powershell-external-services
description: Implement or review PowerShell integrations with Graph, REST, credentials, deprecations, and testable external-service boundaries.
---

# PowerShell External Services

Use this skill when a PowerShell change touches an external system.

- Prefer the Microsoft Graph PowerShell SDK when it provides the required behavior; justify raw REST when it does not.
- Verify commands, parameters, and service contracts from authoritative sources before relying on them. Do not invent APIs.
- Never hardcode, emit, or log credentials, tokens, tenant identifiers, or secrets. Validate external input and report safe contextual errors.
- Isolate integrations so tests can mock them without live calls. Treat retries, pagination, side effects, and deprecation as explicit behavior.
- Use a supported alternative or document a migration path when an unavoidable dependency is deprecated.
