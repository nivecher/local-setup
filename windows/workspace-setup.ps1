# Windows Development Environment Setup Script
#
# Purpose:
#   Sets up a Windows development environment with common tools including:
#   - Git for Windows
#   - Python and pip
#   - Visual Studio Code
#   - Windows Terminal
#   - PowerShell 7
#
# Requirements:
#   - Must be run as administrator
#   - Internet connection for downloads
#

# Ensure running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Please run this script as Administrator"
    Exit 1
}

# Install Chocolatey package manager if not already installed
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Array of packages to install
$packages = @(
    "git",
    "python",
    "vscode",
    "microsoft-windows-terminal",
    "powershell-core",
    "nodejs",
    "curl",
    "wget"
)

# Install packages
foreach ($package in $packages) {
    Write-Output "Installing $package..."
    choco install $package -y
}

# Create symbolic links for python if they don't exist
if (!(Test-Path "C:\Python\python.exe")) {
    Write-Output "Creating Python symbolic links..."
    New-Item -ItemType Directory -Force -Path "C:\Python"
    New-Item -ItemType SymbolicLink -Path "C:\Python\python.exe" -Target "C:\Python39\python.exe"
    New-Item -ItemType SymbolicLink -Path "C:\Python\pip.exe" -Target "C:\Python39\Scripts\pip.exe"
}

# Configure Git
Write-Output "Configuring Git..."
git config --global core.autocrlf true
git config --global init.defaultBranch main

# Install common Python packages
Write-Output "Installing Python packages..."
pip install virtualenv pytest black flake8

# Remind user to set up Git credentials
Write-Output "`nSetup complete!`n"
Write-Output "Remember to configure Git with your credentials:"
Write-Output "git config --global user.name 'Your Name'"
Write-Output "git config --global user.email 'your.email@example.com'"

Write-Output "`nDone! Please restart your computer to ensure all changes take effect."
