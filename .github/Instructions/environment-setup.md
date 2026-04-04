# Environment Setup: PowerShell 7.6.0 Engineering Lab

## Overview

This repository utilizes a **Container-First** development strategy. The environment is designed to be "Zero-Footprint" on the host OS while providing a strictly governed, high-performance workspace for advanced PowerShell engineering.

By moving the development engine into a Linux-based container, we ensure absolute environmental parity between development, testing, and production execution.

---

## Technical Stack

* **Base Engine:** PowerShell 7.6.0 (LTS) on Ubuntu 22.04.
* **Isolation:** Docker Desktop via WSL 2 backend.
* **Editor:** VS Code with Dev Containers extension.
* **Governance:** `.editorconfig` (LF line endings) and `PSScriptAnalyzer`.
* **Assistance:** GitHub Copilot configured via `.github/copilot-instructions.md`.

---

## Prerequisites

Before opening this project, ensure your host machine (Windows) is configured as follows:

1. **WSL 2:** Installed and updated (`wsl --update`).
2. **Docker Desktop:** Configured to use the WSL 2 engine.
3. **VS Code Extensions:**
    * `ms-vscode-remote.remote-containers`
    * `ms-vscode.powershell`
    * `ms-vscode.editorconfig`

---

## Getting Started

### 1. Initializing the Lab

When you open this folder in VS Code, you will see a prompt: **"Folder contains a Dev Container configuration. Reopen in Container."**

* Selecting this triggers the `Dockerfile` build.
* The build automatically installs the Azure CLI and the engineering toolkit (`Pester`, `PSScriptAnalyzer`, `PSReadLine`).

### 2. The Integrated Profile

The environment includes a global PowerShell profile located at `/opt/microsoft/powershell/7/Microsoft.PowerShell_profile.ps1`. Upon launch, this profile:

* Enables **Predictive IntelliSense** (History-based).
* Sets the terminal to **ListView** mode (F2 to toggle).
* Standardizes terminal colors for a professional engineering experience.

---

## Design Principles

* **Environment Determinism:** We use **Pinned Versions** in the `Dockerfile` to prevent configuration drift over time.
* **LF Line Endings:** All files are strictly **LF** (Line Feed) to ensure cross-platform compatibility between the Windows host and the Linux container.
* **Security Isolation:** All Cloud CLI operations (Azure/Graph) are executed within the container's isolated context, protecting the host's primary identity.

---

## The Engineering Philosophy

This repository is built on a **"Zero Margin for Error"** philosophy—a standard carried over from over a decade of operational experience in high-stakes, high-consequence physical environments.

### Core Tenets of This Lab

* **The Gold Image Standard:** Just as a physical service must be perfect the first time, our automation environment must be deterministic. We use containers to eliminate "it works on my machine" variability.
* **Process Integrity:** Code is not just logic; it is a service. We use strict linting (`PSScriptAnalyzer`) and comprehensive testing (`Pester`) to ensure that every script performs exactly as promised.
* **Respect for the State:** Any function that changes a system's state must support `-WhatIf` and `-Confirm`. We treat every production environment with the same respect and caution as a high-stakes physical operation.
* **Clean Room Development:** By using a "Zero-Footprint" Docker environment, we ensure that our development tools do not pollute the host system, and the host system does not bias our development.

---

## Troubleshooting

* **Module Not Found:** If a pre-installed module is missing, run `F1 > Dev Containers: Rebuild Container` to force a clean layer refresh.
* **Line Ending Errors:** If Git reports CRLF issues, verify your local `git config core.autocrlf` is set to `input` or `false`.
* **Identity Issues:** If Azure CLI commands fail, run `az login` within the container terminal to re-authenticate the session.
