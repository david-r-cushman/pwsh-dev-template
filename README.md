# PowerShell 7.4 LTS: Hardened Engineering Lab

## 🛡️ The Mission: "Zero-Footprint" Security

In an era of increasing supply chain threats—such as the **March 2026 Axios RAT** incident—local development environments are often the weakest link. This repository provides a **Hardened Infrastructure Lab** designed to isolate the development process from the host operating system.

By utilizing **Docker Dev Containers**, this environment ensures that third-party module execution, cloud CLI operations, and script testing occur within a strictly governed, ephemeral Linux sandbox.

---

## 🏗️ Architecture & Stack

This lab is built on a "Gold Image" philosophy, ensuring absolute environmental parity across any machine with Docker and VS Code.

* **Runtime:** PowerShell 7.4.x (LTS) on Ubuntu 22.04.
* **Virtualization:** Docker Desktop via WSL 2 backend.
* **Isolation Strategy:** * **No Host Bind-Mounts:** Prevents "portal" leakage of Windows host credentials (SSH keys, browser cookies) into the container.
    * **Non-Persistent Identity:** Designed for ephemeral authentication via Azure CLI (`az login`).
* **Governance:** Integrated `PSScriptAnalyzer` for linting and `EditorConfig` for cross-platform formatting (LF line endings).

---

## 🚀 Key Features

### 1. Automated Tooling Injection

The `Dockerfile` automatically provisions a professional engineering toolkit:
* **Pester:** For Unit and Integration testing.
* **PSScriptAnalyzer:** To enforce community best practices and security rules.
* **Azure CLI:** Pre-installed for cloud resource management.
* **PSReadLine:** Configured for a high-performance terminal experience.

### 2. Tailored Developer Experience

The environment injects a specialized PowerShell profile that activates:
* **Predictive IntelliSense:** Leveraging local command history.
* **ListView Completion:** High-visibility menu navigation (F2 toggle).
* **Visual Feedback:** Cyan-coded environment verification upon successful container load.

---

## 🛠️ Prerequisites & Setup

1. **Host OS:** Windows 11 with WSL 2 enabled.
2. **Tools:** Docker Desktop and VS Code with the **Dev Containers** extension.
3. **Launch:** Open the folder in VS Code and select **"Reopen in Container"** when prompted.

---

## 📜 The Engineering Philosophy

> *"Zero Margin for Error"*

This lab carries over a decade of high-stakes operational experience into the world of Infrastructure as Code (IaC).

* **Deterministic Builds:** We use pinned versions in the `Dockerfile` to eliminate "it works on my machine" variability.
* **Process Integrity:** Code is not just logic; it is a service. We use strict linting (`PSScriptAnalyzer`) and comprehensive testing (`Pester`) to ensure that every script performs exactly as promised.
* **Respect for the State:** Any function that changes a system's state must support `-WhatIf` and `-Confirm` parameters, treating production systems with the same care as a high-consequence physical environment.
* **Clean Room Development:** Development tools should not pollute the host system, and the host system should not bias development.

---

## 🔍 Troubleshooting

* **Rebuilding:** For a clean state, use `F1 > Dev Containers: Rebuild Container Without Cache` to force a clean layer refresh.
* **Line Ending Errors:** Verify your local `git config core.autocrlf` is set to `input` or `false`.
* **Identity Issues:** Run `az login` inside the container terminal to authenticate your cloud session; credentials remain scoped to the container instance.
