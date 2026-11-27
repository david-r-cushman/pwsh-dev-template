# Base runtime for the template's development environment.
FROM mcr.microsoft.com/dotnet/sdk:10.0-noble@sha256:8c6edfb26c85153f236d26efebd9ad349aec403583f343f201ee67838b23658d

ARG POWERSHELL_VERSION=7.6
ARG PESTER_VERSION=6.0.0
ARG PSSCRIPTANALYZER_VERSION=1.25.0
ARG PSREADLINE_VERSION=2.4.5

# The .NET SDK image supplies PowerShell. Keep the template on the approved LTS branch.
RUN pwsh -NoProfile -Command " \
    \$RequiredVersion = [version]'${POWERSHELL_VERSION}'; \
    \$Version = \$PSVersionTable.PSVersion; \
    if (\$Version.Major -ne \$RequiredVersion.Major -or \$Version.Minor -ne \$RequiredVersion.Minor) { \
        throw \"Expected PowerShell \${RequiredVersion}.x; detected \$Version.\" \
    }; \
    Write-Output \"PowerShell version validated: \$Version\""

# Minimal system tooling required for package installation and source control.
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    git \
    && rm -rf /var/lib/apt/lists/*

# Cloud tooling is installed in the container so host authentication state does not need
# to be mixed into normal project development on the workstation.
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Baseline PowerShell tooling for testing, analysis, and shell usability.
RUN pwsh -NoProfile -Command " \
    \$ErrorActionPreference = 'Stop'; \
    Install-Module -Name 'Pester' -RequiredVersion '${PESTER_VERSION}' -Force -AllowClobber -Scope AllUsers; \
    Install-Module -Name 'PSScriptAnalyzer' -RequiredVersion '${PSSCRIPTANALYZER_VERSION}' -Force -AllowClobber -Scope AllUsers; \
    Install-Module -Name 'PSReadLine' -RequiredVersion '${PSREADLINE_VERSION}' -Force -AllowClobber -Scope AllUsers; \
    "

# The container profile enables a predictable interactive shell experience for
# anyone using a repository created from this template.
RUN pwsh -NoProfile -Command " \
    \$ProfilePath = \$PROFILE.AllUsersAllHosts; \
    \$ProfileDirectory = Split-Path -Parent \$ProfilePath; \
    New-Item -ItemType Directory -Path \$ProfileDirectory -Force | Out-Null; \
    'Import-Module PSReadLine' | Out-File -FilePath \$ProfilePath -Encoding utf8 -Force; \
    'Set-PSReadLineOption -PredictionSource History' | Add-Content -Path \$ProfilePath; \
    'Set-PSReadLineOption -PredictionViewStyle ListView' | Add-Content -Path \$ProfilePath; \
    'Write-Host \"--- PowerShell \$(\$PSVersionTable.PSVersion) Template Environment Loaded ---\" -ForegroundColor Cyan' | Add-Content -Path \$ProfilePath; \
    "

# Default workspace root used by the dev container.
WORKDIR /workspaces
