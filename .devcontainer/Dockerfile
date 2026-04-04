# 1. Foundation: Pinned LTS version
# FROM mcr.microsoft.com/powershell:lts-ubuntu-22.04
FROM mcr.microsoft.com/powershell:7.4-ubuntu-22.04

# 2. System Tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 3. Cloud Identity: Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# 4a. Professional Toolkit: Quality & Experience
RUN pwsh -Command " \
    \$ErrorActionPreference = 'Stop'; \
    Install-Module -Name 'Pester', 'PSScriptAnalyzer', 'PSReadLine' -Force -AllowClobber -Scope AllUsers; \
    "

# 4b. Install GitHub CLI & Copilot Extension
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install gh -y \
    # && pwsh -Command "gh extension install github/gh-copilot --force"

    # 5. User Experience: Force Predictive IntelliSense & Coloring
    # This creates a global profile that every session will load
    RUN pwsh -Command " \
    \$ProfilePath = \"\$PSHOME/Microsoft.PowerShell_profile.ps1\"; \
    'Import-Module PSReadLine' | Out-File -FilePath \$ProfilePath -Encoding utf8; \
    'Set-PSReadLineOption -PredictionSource History' | Out-File -FilePath \$ProfilePath -Append -Encoding utf8; \
    'Set-PSReadLineOption -PredictionViewStyle ListView' | Out-File -FilePath \$ProfilePath -Append -Encoding utf8; \
    'Set-PSReadLineOption -Colors @{ InlinePrediction = \"#888888\" }' | Out-File -FilePath \$ProfilePath -Append -Encoding utf8; \
    'Write-Host \"--- PowerShell 7.4.x Engineering Lab Loaded ---\" -ForegroundColor Cyan' | Out-File -FilePath \$ProfilePath -Append -Encoding utf8; \
    "

# 6. Workspace
WORKDIR /workspaces
