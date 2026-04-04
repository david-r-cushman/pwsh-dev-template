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

# 4b. Install GitHub CLI & Bake-in Copilot Extension
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install gh git -y \
    && mkdir -p /root/.local/share/gh/extensions/gh-copilot \
    && git clone https://github.com/github/gh-copilot /root/.local/share/gh/extensions/gh-copilot

# 5. User Experience & Copilot Alias
RUN pwsh -Command " \
    \$ProfilePath = \"\$PSHOME/Microsoft.PowerShell_profile.ps1\"; \
    'Import-Module PSReadLine' | Out-File -FilePath \$ProfilePath -Encoding utf8; \
    'Set-PSReadLineOption -PredictionSource History' | Out-File -FilePath \$ProfilePath -Append -Encoding utf8; \
    'function copilot { gh copilot \$args }' | Out-File -FilePath \$ProfilePath -Append -Encoding utf8; \
    'Write-Host \"--- PowerShell 7.4.x Engineering Lab Loaded ---\" -ForegroundColor Cyan' | Out-File -FilePath \$ProfilePath -Append -Encoding utf8; \
    "

# 6. Workspace
WORKDIR /workspaces
