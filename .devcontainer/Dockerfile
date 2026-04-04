# 1. Foundation: Pinned LTS version
FROM mcr.microsoft.com/powershell:7.4-ubuntu-22.04

# 2. System Tools & Modern Node.js v24 (LTS)
RUN apt-get update && apt-get install -y curl ca-certificates gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install -y \
    git \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# 3. Cloud Identity: Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# 4. Professional Toolkit: Quality & Experience
# We removed the GH CLI install here because the "Feature" in devcontainer.json handles it.
RUN pwsh -Command " \
    \$ErrorActionPreference = 'Stop'; \
    Install-Module -Name 'Pester', 'PSScriptAnalyzer', 'PSReadLine' -Force -AllowClobber -Scope AllUsers; \
    "

# 5. User Experience & Copilot Function
# This bakes the "copilot" command directly into the PowerShell profile.
RUN pwsh -Command " \
    \$ProfilePath = \"\$PSHOME/Microsoft.PowerShell_profile.ps1\"; \
    'Import-Module PSReadLine' | Out-File -FilePath \$ProfilePath -Encoding utf8; \
    'Set-PSReadLineOption -PredictionSource History' | Out-File -FilePath \$ProfilePath -Append -Encoding utf8; \
    'Set-PSReadLineOption -PredictionViewStyle ListView' | Out-File -FilePath \$ProfilePath -Append -Encoding utf8; \
    'Write-Host \"--- PowerShell 7.4.x Engineering Lab Loaded ---\" -ForegroundColor Cyan' | Out-File -FilePath \$ProfilePath -Append -Encoding utf8; \
    "

# 6. Workspace
WORKDIR /workspaces
