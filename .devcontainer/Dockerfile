# 1. Foundation: Pinned LTS version
FROM mcr.microsoft.com/powershell:lts-ubuntu-22.04
# FROM mcr.microsoft.com/powershell:7.6.0-ubuntu-22.04

# 2. System Tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 3. Cloud Identity: Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# 4. Professional Toolkit: Quality & Experience
RUN pwsh -Command " \
    \$ErrorActionPreference = 'Stop'; \
    Install-Module -Name 'Pester', 'PSScriptAnalyzer', 'PSReadLine' -Force -AllowClobber -Scope AllUsers; \
    "

# 5. User Experience: Force Predictive IntelliSense & Coloring
# This creates a global profile that every session will load
RUN pwsh -Command " \
    \$ProfilePath = '/opt/microsoft/powershell/7/Microsoft.PowerShell_profile.ps1'; \
    \$ProfileContent = @' \
    Import-Module PSReadLine; \
    Set-PSReadLineOption -PredictionSource History; \
    Set-PSReadLineOption -PredictionViewStyle ListView; \
    Set-PSReadLineOption -Colors @{ InlinePrediction = \"#888888\" }; \
    Write-Host '--- PowerShell 7.6.0 Engineering Lab Loaded ---' -ForegroundColor Cyan; \
    '@; \
    Set-Content -Path \$ProfilePath -Value \$ProfileContent -Force; \
    "

# 6. Workspace
WORKDIR /workspaces
