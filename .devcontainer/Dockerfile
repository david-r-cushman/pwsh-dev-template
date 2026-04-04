# Use the official Microsoft PowerShell image as a base
FROM mcr.microsoft.com/powershell:lts-ubuntu-22.04

# Install any system-level dependencies (like git for your GitOps work)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Pre-install the modules you use most often
# This ensures every time you open this container, your environment is ready.
RUN pwsh -Command "Install-Module -Name 'PSWindowsUpdate', 'PSAppDeploymentToolkit' -Force"

# Set the working directory inside the container
WORKDIR /workspaces/my-automation-project