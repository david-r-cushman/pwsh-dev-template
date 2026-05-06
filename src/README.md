# Source Layout

This template supports both script-first and module-first PowerShell projects.

## Script-first

- Place script code under `src/` (and optionally organize into subfolders).
- Keep reusable functions in their own files under `src/Public` and `src/Private` when that helps testability and reuse.

## Module-first

This folder already contains the common module layout:

- `Public/` exported functions (one public function per file)
- `Private/` internal helpers
- `Classes/` class definitions (if used)

To use this repository as a module project, rename the scaffolded module files:

- `src/TemplateModule.psd1` -> `src/<YourModuleName>.psd1`
- `src/TemplateModule.psm1` -> `src/<YourModuleName>.psm1`

Then update the manifest metadata as needed.

